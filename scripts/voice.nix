{ pkgs }:

# Voice control
#
#   voice on             open the mic    <- press
#   voice off            close the mic   <- release
#   voice toggle         toggle
#
#   voice preset NAME    load a preset (see easyeffects preset)
#   voice status
pkgs.writeShellScriptBin "voice" ''
  set -euo pipefail

  MIC="@DEFAULT_AUDIO_SOURCE@"
  EE_NODE="easyeffects_source"

  EE=(easyeffects)

  case "''${1:-}" in
    on)     wpctl set-mute "$MIC" 0 ;;
    off)    wpctl set-mute "$MIC" 1 ;;
    toggle) wpctl set-mute "$MIC" toggle ;;

    preset)
      [ $# -ge 2 ] || { echo "usage: voice preset NAME" >&2; exit 1; }
      "''${EE[@]}" -l "$2"
      ;;

    status)
      wpctl get-volume "$MIC" | grep -c MUTED >/dev/null && MIC_STATE=muted || MIC_STATE=live
      pw-link -l 2>/dev/null | grep -c "^''${EE_NODE}:capture" >/dev/null && LINK=linked || LINK=unlinked
      PRESET=$("''${EE[@]}" -a input 2>/dev/null)
      echo "mic:$MIC_STATE link:$LINK preset:$PRESET"
      ;;

    *)
      echo "usage: voice {on|off|toggle|preset NAME|status}" >&2
      exit 1
      ;;
  esac
''
