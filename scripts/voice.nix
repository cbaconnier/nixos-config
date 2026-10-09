{ pkgs }:

# Voice control
#
#   voice on             open the mic    <- press
#   voice off            close the mic   <- release
#   voice toggle         toggle
#
#   voice listen         hear the voice in the speakers
#   voice unlisten       stop hearing it
#
#   voice preset NAME    load a preset (see easyeffects preset)
#   voice status
pkgs.writeShellScriptBin "voice" ''
  set -euo pipefail

  MIC="@DEFAULT_AUDIO_SOURCE@"
  EE_NODE="easyeffects_source"

  EE=(easyeffects)
  LISTEN_UNIT="voice-listen"

  case "''${1:-}" in
    on)     wpctl set-mute "$MIC" 0 ;;
    off)    wpctl set-mute "$MIC" 1 ;;
    toggle) wpctl set-mute "$MIC" toggle ;;

    # Monitoring: a loopback from the EasyEffects source to the default output, run as a
    # transient user service.
    listen)
      systemctl --user is-active --quiet "$LISTEN_UNIT" \
        || systemd-run --user --quiet --unit="$LISTEN_UNIT" ${pkgs.pipewire}/bin/pw-loopback -C "$EE_NODE"
      ;;
    unlisten) systemctl --user stop "$LISTEN_UNIT" 2>/dev/null || true ;;

    preset)
      [ $# -ge 2 ] || { echo "usage: voice preset NAME" >&2; exit 1; }
      "''${EE[@]}" -l "$2"
      ;;

    status)
      wpctl get-volume "$MIC" | grep -c MUTED >/dev/null && MIC_STATE=muted || MIC_STATE=live
      pw-link -l 2>/dev/null | grep -c "^''${EE_NODE}:capture" >/dev/null && LINK=linked || LINK=unlinked
      PRESET=$("''${EE[@]}" -a input 2>/dev/null)
      systemctl --user is-active --quiet "$LISTEN_UNIT" && LISTEN=on || LISTEN=off
      echo "mic:$MIC_STATE link:$LINK preset:$PRESET listen:$LISTEN"
      ;;

    *)
      echo "usage: voice {on|off|toggle|listen|unlisten|preset NAME|status}" >&2
      exit 1
      ;;
  esac
''
