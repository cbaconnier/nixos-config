{
  config,
  lib,
  pkgs,
  ...
}:
let
  location = {
    lat = "46.52N";
    lon = "6.63E";
  };
  protect = [
    "Feu cheminée"
    "prisme"
    "Confusion"
    "Sourires rayonnants"
    "Brume de novembre"
    "Sous l'arbre"
    "Neige scintillante"
    "Veilleuse"
  ];
  rooms = [
    {
      name = "Sejour";
      scene = "Repos";
      minutes = 20;
      at = "20:00";
    }
    {
      name = "Chambre";
      scene = "Repos";
      minutes = 20;
      at = "sunset";
    }
  ];

  hueCtl = import ../../../scripts/hue-ctl.nix { inherit pkgs; };

  hueDusk = pkgs.writeShellApplication {
    name = "hue-dusk";
    runtimeInputs = [
      hueCtl
      pkgs.jq
    ];
    text = ''
      usage() { echo "usage: hue-dusk [--dry-run] <room> <scene> <minutes>" >&2; exit 1; }
      dry=0
      if [ "''${1:-}" = --dry-run ]; then dry=1; shift; fi
      [ $# -eq 3 ] || usage
      room=$1 scene=$2 minutes=$3
      export HUE_BRIDGE=''${HUE_BRIDGE:-192.168.1.98}

      log() { echo "level=$1 event=$2 room=\"$room\" $3"; }

      state=$(hue-ctl state) || { log error bridge_unreachable ""; exit 1; }
      rows=$(jq -r --arg room "$room" --arg scene "$scene" --argjson minutes "$minutes" \
        --argjson protect ${lib.escapeShellArg (builtins.toJSON protect)} -f ${./decide.jq} <<< "$state")

      while IFS=$'\t' read -r id name reason bri to cmd; do
        if [ -z "$name" ]; then
          continue
        elif [ "$reason" != ok ]; then
          log info lamp_skipped "lamp=\"$name\" reason=\"$reason\""
        elif [ $dry -eq 1 ]; then
          log info would_fade "lamp=\"$name\" bri_from=$bri bri_to=$to minutes=$minutes"
        elif hue-ctl light "$id" "$cmd"; then
          log info fade_start "lamp=\"$name\" bri_from=$bri bri_to=$to minutes=$minutes"
        else
          log error fade_failed "lamp=\"$name\""
        fi
      done <<< "$rows"
    '';
  };

  unitName = room: "hue-dusk-${lib.toLower room.name}";
in
{
  imports = [ ../hue.nix ];

  environment.systemPackages = [ hueDusk ];

  systemd.services = lib.listToAttrs (
    map (
      room:
      lib.nameValuePair (unitName room) {
        description = "Dim ${room.name} Hue lights at dusk";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        path = [
          hueDusk
          pkgs.sunwait
        ];
        serviceConfig = {
          Type = "oneshot";
          DynamicUser = true;
          LoadCredential = "key:${config.age.secrets.hue-api-key.path}";
          TimeoutStartSec = "infinity";
        };
        script = ''
          export HUE_KEY_FILE="$CREDENTIALS_DIRECTORY/key"
          ${lib.optionalString (room.at == "sunset")
            ''[ "$(sunwait poll ${location.lat} ${location.lon})" = DAY ] && sunwait wait set ${location.lat} ${location.lon}''
          }
          exec hue-dusk ${
            lib.escapeShellArgs [
              room.name
              room.scene
              (toString room.minutes)
            ]
          }
        '';
      }
    ) rooms
  );

  # Sunset rooms start early and let sunwait sleep until sunset.
  systemd.timers = lib.listToAttrs (
    map (
      room:
      lib.nameValuePair (unitName room) {
        wantedBy = [ "timers.target" ];
        timerConfig.OnCalendar = if room.at == "sunset" then "14:00" else room.at;
      }
    ) rooms
  );
}
