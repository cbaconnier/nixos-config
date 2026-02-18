{ pkgs, ... }:
pkgs.writeShellScriptBin "remind" ''
  TARGET=''${1:-}
  MESSAGE=''${2:-}
  SOUND="/run/current-system/sw/share/sounds/freedesktop/stereo/message-new-instant.oga"

  [[ "$TARGET" =~ ^([0-9]{2}):([0-9]{2})$ ]] || { echo "Usage: remind HH:MM [\"message\"]"; exit 1; }

  H=''${BASH_REMATCH[1]}
  M=''${BASH_REMATCH[2]}

  NOW=$(date +%s)
  TARGET_TS=$(date -d "today $H:$M" +%s)
  (( TARGET_TS <= NOW )) && TARGET_TS=$(date -d "tomorrow $H:$M" +%s)
  TOTAL=$(( TARGET_TS - NOW ))

  cleanup() {
      pkill -P "$ALARM_PID" 2>/dev/null
      kill "$ALARM_PID" 2>/dev/null
      tput cnorm; tput rmcup
  }
  trap cleanup EXIT

  tput smcup; tput civis

  for (( i=TOTAL; i>=0; i-- )); do
      tput clear
      printf '%02d:%02d remaining — %s%s\n' $(( i/60 )) $(( i%60 )) "$TARGET" "''${MESSAGE:+ : $MESSAGE}"
      sleep 1
  done

  tput clear
  echo "''${TARGET}''${MESSAGE:+ : $MESSAGE}" | ${pkgs.toilet}/bin/toilet --font term --metal -F border

  while true; do ${pkgs.vorbis-tools}/bin/ogg123 -q "$SOUND"; sleep 0.5; done &
  ALARM_PID=$!

  read -r
''
