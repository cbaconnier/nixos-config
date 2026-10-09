{ pkgs }:

# Switch voice effect
#
#   voice-mode default         hardware mic + its default EasyEffects preset
#   voice-mode banshee         banshee virtual mic + empty EasyEffects preset
#   voice-mode dragon          dragon virtual mic + empty EasyEffects preset
#   voice-mode double-entity   double-entity virtual mic + empty EasyEffects preset
#   voice-mode storyteller     storyteller virtual mic + empty EasyEffects preset
#
# EasyEffects stays between the source and everything else; a mode only changes the
# system default source and the EasyEffects input preset. Virtual voices are the systemd
# user services of hosts-config/virtual-voices.
pkgs.writeShellScriptBin "voice-mode" ''
  set -euo pipefail

  # Name of the hardware mic in use to keep as default.
  state="$XDG_RUNTIME_DIR/voice-mic"

  # Print the hardware mic node name.
  # The current default source if it is an ALSA input, otherwise the one remembered in $state.
  hardware_mic() {
    local cur
    cur=$(${pkgs.wireplumber}/bin/wpctl inspect @DEFAULT_AUDIO_SOURCE@ \
      | sed -n 's/.*node\.name = "\(.*\)".*/\1/p' | head -1)
    case "$cur" in
      alsa_input.*) echo "$cur" > "$state" ;;
      *) [ -f "$state" ] || { echo "no hardware mic selected" >&2; exit 1; } ;;
    esac
    cat "$state"
  }

  # Print the EasyEffects preset for the hardware mic $1, no effects for an unknown mic.
  default_preset() {
    case "$1" in
      alsa_input.usb-Audio_Technica_Corp_ATR2100x-USB_Microphone-*) echo atr2100x-default ;;
      alsa_input.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-*) echo rode-default ;;
      *) echo blank_input ;;
    esac
  }

  # Make source $1 the system default and load EasyEffects input preset $2. 
  use() {
    ${pkgs.pipewire}/bin/pw-metadata -n default 0 default.configured.audio.source \
      "{\"name\":\"$1\"}" Spa:String:JSON > /dev/null
    easyeffects -l "$2"
  }

  # Virtual voice services, see hosts-config/virtual-voices.
  voices="banshee dragon double-entity storyteller"

  # Stop every virtual voice service except $1.
  stop_voices_except() {
    for v in $voices; do [ "$v" = "$1" ] || systemctl --user stop "$v"; done
  }

  mode="''${1:-}"
  case " default $voices " in
    *" $mode "*) ;;
    *)
      echo "usage: voice-mode {default|''${voices// /|}}" >&2
      exit 1
      ;;
  esac

  # Also records the hardware mic, which the voice services read at startup.
  mic=$(hardware_mic)

  case "$mode" in
    default)
      use "$mic" "$(default_preset "$mic")"
      stop_voices_except ""
      ;;
    *)
      stop_voices_except "$mode"
      systemctl --user start "$mode"
      use "''${mode}_source" blank_input
      ;;
  esac
''
