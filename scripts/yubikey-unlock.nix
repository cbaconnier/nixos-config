{ pkgs }:

# Ask yubikey PIN in a rofi popup
pkgs.writeShellScriptBin "yubikey-unlock" ''
  cancelled="$XDG_RUNTIME_DIR/yubikey-unlock.cancelled"

  # ssh-add runs this script again to ask the PIN
  if [ -n "$YUBIKEY_UNLOCK_ASKPASS" ]; then
    # Own pid file, so the Bitwarden rofi can open while this popup is shown
    ${pkgs.rofi}/bin/rofi -dmenu -password -p "YubiKey PIN" \
      -pid "$XDG_RUNTIME_DIR/rofi-yubikey.pid" \
      -theme "$HOME/.config/rofi/config-popup.rasi" \
      -theme-str 'mainbox { children: [inputbar]; padding: 0px 0px 20px 0px; }' \
      </dev/null || touch "$cancelled"
    exit 0
  fi

  export SSH_AUTH_SOCK=''${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/ssh-agent}
  export YUBIKEY_UNLOCK_ASKPASS=1 SSH_ASKPASS="$0" SSH_ASKPASS_REQUIRE=force

  # The YubiKey blocks the PIN after 3 wrong attempts in a row
  for _ in 1 2 3; do
    rm -f "$cancelled"
    err=$(${pkgs.openssh}/bin/ssh-add -K 2>&1) && exit 0
    [ -e "$cancelled" ] && exit 1
    # No YubiKey: asking again won't help. Anything else is a wrong PIN ("invalid format").
    [[ $err == *"device not found"* ]] && { echo "$err" >&2; exit 1; }
  done

  ${pkgs.rofi}/bin/rofi -e "Wrong PIN 3 times. Unplug and replug your YubiKey." \
    -pid "$XDG_RUNTIME_DIR/rofi-yubikey.pid" \
    -theme "$HOME/.config/rofi/config-popup.rasi"
  exit 1
''
