{ pkgs }:

# Ask yubikey PIN in a rofi popup
pkgs.writeShellScriptBin "yubikey-unlock" ''
  # ssh-add runs this script again to ask the PIN
  if [ -n "$YUBIKEY_UNLOCK_ASKPASS" ]; then
    # Own pid file, so the Bitwarden rofi can open while this popup is shown
    exec ${pkgs.rofi}/bin/rofi -dmenu -password -p "YubiKey PIN" \
      -pid "$XDG_RUNTIME_DIR/rofi-yubikey.pid" \
      -theme "$HOME/.config/rofi/config-popup.rasi" \
      -theme-str 'mainbox { children: [inputbar]; padding: 0px 0px 20px 0px; }' </dev/null
  fi

  export SSH_AUTH_SOCK=''${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/ssh-agent}
  YUBIKEY_UNLOCK_ASKPASS=1 SSH_ASKPASS="$0" SSH_ASKPASS_REQUIRE=force \
    exec ${pkgs.openssh}/bin/ssh-add -K
''
