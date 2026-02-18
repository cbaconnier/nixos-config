{ pkgs, ... }:
pkgs.writeShellScriptBin "tea" ''
  MINUTES=''${1:-"5"}
  TOTAL=$(( MINUTES * 60 ))
  SOUND="/run/current-system/sw/share/sounds/freedesktop/stereo/message-new-instant.oga"

  [[ "$MINUTES" =~ ^[0-9]+$ ]] && (( MINUTES > 0 )) || { echo "Usage: tea [minutes]"; exit 1; }

  cleanup() {
      pkill -P "$ALARM_PID" 2>/dev/null
      kill "$ALARM_PID" 2>/dev/null
      tput cnorm; tput rmcup
  }
  trap cleanup EXIT

  tput smcup; tput civis

  for (( i=TOTAL; i>=0; i-- )); do
      tput clear
      printf '%02d:%02d' $(( i/60 )) $(( i%60 )) | ${pkgs.toilet}/bin/toilet --font future
      sleep 1
  done

  tput clear
  echo "Tea Time!" | ${pkgs.toilet}/bin/toilet --font future

  while true; do ${pkgs.vorbis-tools}/bin/ogg123 -q "$SOUND"; sleep 0.5; done &
  ALARM_PID=$!

  read -r
''
