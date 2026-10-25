{ pkgs }:

# Shared building blocks for the virtual voices: every voice is a PipeWire filter-chain
# exposed as a virtual mic (<name>_source), running in its own pipewire process so a
# crashing plugin cannot take the audio server down, and restarted by systemd.
rec {
  # autotalent, patched to load and run inside PipeWire:
  # - linked against libmvec, which the stock build leaves unresolved
  # - a non-finite detected pitch is clamped to 0 instead of indexing iNotes[] out of bounds
  autotalent = pkgs.autotalent.overrideAttrs (o: {
    env.NIX_LDFLAGS = "-lmvec";
    postPatch = (o.postPatch or "") + ''
      substituteInPlace autotalent.c --replace-fail \
        "outpitch = (1-fPull)*outpitch + fPull*fFixed;" \
        "outpitch = (1-fPull)*outpitch + fPull*fFixed; if (!(outpitch > -1000.0f && outpitch < 1000.0f)) outpitch = 0;"
    '';
  });

  # LADSPA_PATH / LV2_PATH of the voice processes.
  plugins = pkgs.symlinkJoin {
    name = "virtual-voice-plugins";
    paths = [
      autotalent
      pkgs.ladspaPlugins
      pkgs.lsp-plugins
      pkgs.zam-plugins
      pkgs.mda_lv2
    ];
  };

  lsp = "http://lsp-plug.in/plugins/lv2/";

  # Graph node constructors.
  ladspa = name: plugin: label: control: {
    type = "ladspa";
    inherit
      name
      plugin
      label
      control
      ;
  };
  lv2 = name: plugin: control: {
    type = "lv2";
    inherit name plugin control;
  };
  builtin = name: label: control: {
    type = "builtin";
    inherit name label control;
  };
  link = output: input: { inherit output input; };

  # systemd user service of the voice `name`. `voice` has a `description` and a filter
  # graph (`nodes`, `links`, `inputs`, `outputs`). The mic is not part of the config:
  # voice-mode writes the hardware mic name to $XDG_RUNTIME_DIR/voice-mic.
  service =
    name: voice:
    let
      # `micgain` is a fixed gain in front of every voice. The Rode NT USB at 25% volume is
      # about 14 dB quieter than the ATR2100x, so it gets a config with a gain of 5; the
      # wrapper below picks the config from the mic voice-mode recorded.
      args = micgain: {
        "node.description" = voice.description;
        "filter.graph" = {
          # fixed gain in front of the voice, see `micgain` above
          nodes = [ (builtin "micgain" "linear" { Mult = micgain; }) ] ++ voice.nodes;
          links = [ (link "micgain:Out" (builtins.head voice.inputs)) ] ++ voice.links;
          inputs = [ "micgain:In" ];
          inherit (voice) outputs;
        };
        # Raw mic in, linked by link-mic. node.autoconnect is off so EasyEffects does not
        # redirect the stream to its own source.
        "capture.props" = {
          "node.name" = "${name}_capture";
          "node.passive" = true;
          "node.autoconnect" = false;
          "audio.rate" = 48000;
          "audio.position" = [ "MONO" ];
        };
        "playback.props" = {
          "node.name" = "${name}_source";
          "node.description" = voice.description;
          "media.class" = "Audio/Source";
          "audio.rate" = 48000;
          "audio.position" = [ "MONO" ];
          # Low priority: never picked as default source unless selected explicitly.
          "priority.session" = 10;
        };
      };

      config =
        micgain:
        pkgs.writeText "${name}.conf" (
          builtins.toJSON {
            "context.modules" = [
              { name = "libpipewire-module-protocol-native"; }
              { name = "libpipewire-module-client-node"; }
              { name = "libpipewire-module-adapter"; }
              {
                name = "libpipewire-module-filter-chain";
                args = args micgain;
              }
            ];
          }
        );

      run = pkgs.writeShellScript "${name}-run" ''
        case "$(cat "$XDG_RUNTIME_DIR/voice-mic")" in
          alsa_input.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-*) conf=${config 5.0} ;;
          *) conf=${config 1.0} ;;
        esac
        exec ${pkgs.pipewire}/bin/pipewire -c "$conf"
      '';

      # Wait for the capture port, then link the hardware mic to it.
      link-mic = pkgs.writeShellScript "${name}-link-mic" ''
        plink=${pkgs.pipewire}/bin/pw-link
        mic=$(cat "$XDG_RUNTIME_DIR/voice-mic")
        for _ in $(seq 50); do
          $plink -i | grep -q '^${name}_capture:input_MONO$' && break
          sleep 0.2
        done
        $plink "$($plink -o | grep -m1 "^$mic:capture_")" ${name}_capture:input_MONO
      '';
    in
    {
      description = "${voice.description} voice";
      bindsTo = [ "pipewire.service" ];
      after = [
        "pipewire.service"
        "wireplumber.service"
      ];
      environment = {
        LADSPA_PATH = "${plugins}/lib/ladspa";
        LV2_PATH = "${plugins}/lib/lv2";
      };
      serviceConfig = {
        ExecStart = "${run}";
        ExecStartPost = "${link-mic}";
        Restart = "on-failure";
        RestartSec = 1;
      };
    };
}
