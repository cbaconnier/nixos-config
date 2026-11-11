{ pkgs }:

pkgs.writeShellScriptBin "bw-pinentry" ''
  set -u
  export XDG_RUNTIME_DIR=''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}

  prompt="Master password"
  err=""
  echo "OK Pleased to meet you"

  while IFS= read -r line; do
    case "$line" in
      SETPROMPT\ *)
        prompt=''${line#SETPROMPT }
        echo OK
        ;;
      SETERROR\ *)
        err=''${line#SETERROR }
        echo OK
        ;;
      GETPIN*)
        children="inputbar"
        [ -z "$err" ] || children="inputbar, message"
        if pw=$(${pkgs.rofi}/bin/rofi -theme ~/.config/rofi/config-popup.rasi -dmenu -password \
          -p "$prompt" -mesg "$err" \
          -theme-str "mainbox { children: [$children]; padding: 0px 0px 20px 0px; }" \
          </dev/null); then
          pw=''${pw//%/%25}
          pw=''${pw//$'\r'/%0D}
          pw=''${pw//$'\n'/%0A}
          echo "D $pw"
          echo OK
        else
          echo "ERR 83886179 Operation cancelled"
        fi
        err=""
        ;;
      BYE*)
        echo "OK closing connection"
        exit 0
        ;;
      *)
        echo OK
        ;;
    esac
  done
''
