{ pkgs, ... }:
pkgs.writeShellScriptBin "tea" ''
  MINUTES=''${1:-"5"}
  SOUND="/run/current-system/sw/share/sounds/freedesktop/stereo/message-new-instant.oga"
  ALARM_PID=""

  [[ "$MINUTES" =~ ^[0-9]+$ ]] && (( MINUTES > 0 )) || { echo "Usage: tea [minutes]"; exit 1; }

  DEADLINE=$(( $(date +%s) + MINUTES * 60 ))

  cleanup() {
      [[ -n "$ALARM_PID" ]] && { pkill -P "$ALARM_PID" 2>/dev/null; kill "$ALARM_PID" 2>/dev/null; }
      tput cnorm; tput rmcup
  }
  trap cleanup EXIT

  sleep_to_next_second() {
      local ns=$(( 10#$(date +%N) ))
      sleep "$(printf '0.%09d' $(( 1000000000 - ns )))"
  }

  fmt() {
      local s=$1
      if (( s >= 3600 )); then
          printf '%02d:%02d:%02d' $(( s / 3600 )) $(( s % 3600 / 60 )) $(( s % 60 ))
      else
          printf '%02d:%02d' $(( s / 60 )) $(( s % 60 ))
      fi
  }

  tput smcup; tput civis

  while :; do
      REMAINING=$(( DEADLINE - $(date +%s) ))
      (( REMAINING < 0 )) && REMAINING=0
      tput clear
      fmt "$REMAINING" | ${pkgs.toilet}/bin/toilet --font future
      (( REMAINING == 0 )) && break
      sleep_to_next_second
  done

  tput clear
  echo "Tea Time!" | ${pkgs.toilet}/bin/toilet --font future

  while true; do ${pkgs.vorbis-tools}/bin/ogg123 -q "$SOUND"; sleep 0.5; done &
  ALARM_PID=$!

  read -r
''
