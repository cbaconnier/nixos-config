{ pkgs }:

# SSH_ASKPASS that only shows the Quickshell "touch your YubiKey" popup.
# Anything else gets no answer: ssh asks in the terminal.
pkgs.writeShellScriptBin "ssh-askpass-touch" ''
  [ "$SSH_ASKPASS_PROMPT" = none ] || exit 1

  touch_popup() {
    ${pkgs.quickshell}/bin/qs ipc --any-display call yubikey touch "$1" >/dev/null 2>&1
  }

  # ssh stops this script once the YubiKey is touched
  trap 'touch_popup false; exit 0' TERM INT
  touch_popup true
  sleep 30 & wait
  touch_popup false
''
