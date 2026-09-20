{ pkgs, ... }:
pkgs.writeShellScriptBin "remind" ''
  TARGET=''${1:-}
  MESSAGE=''${2:-}
  SOUND="/run/current-system/sw/share/sounds/freedesktop/stereo/message-new-instant.oga"
  ALARM_PID=""

  [[ "$TARGET" =~ ^([0-9]{1,2}):([0-9]{2})$ ]] || { echo "Usage: remind HH:MM [\"message\"]"; exit 1; }

  H=''${BASH_REMATCH[1]}
  M=''${BASH_REMATCH[2]}

  NOW=$(date +%s)
  DEADLINE=$(date -d "today $H:$M" +%s) || exit 1
  (( DEADLINE <= NOW )) && DEADLINE=$(date -d "tomorrow $H:$M" +%s)

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
      printf '%02d:%02d:%02d' $(( s / 3600 )) $(( s % 3600 / 60 )) $(( s % 60 ))
  }

  tput smcup; tput civis

  while :; do
      REMAINING=$(( DEADLINE - $(date +%s) ))
      (( REMAINING < 0 )) && REMAINING=0
      tput clear
      printf '%s remaining — %s%s\n' "$(fmt "$REMAINING")" "$TARGET" "''${MESSAGE:+ : $MESSAGE}"
      (( REMAINING == 0 )) && break
      sleep_to_next_second
  done

  tput clear
  echo "''${TARGET}''${MESSAGE:+ : $MESSAGE}" | ${pkgs.toilet}/bin/toilet --font term --metal -F border

  while true; do ${pkgs.vorbis-tools}/bin/ogg123 -q "$SOUND"; sleep 0.5; done &
  ALARM_PID=$!

  read -r
''
