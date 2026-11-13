{ pkgs }:

let
  filter = "ssh/";

  bindings = [
    {
      key = "alt+c";
      label = "copy";
      spec = "copy:password";
    }
    {
      key = "alt+s";
      label = "sync";
      spec = "sync";
    }
  ];

  keybindings = pkgs.lib.concatMapStringsSep "," (b: "${b.key}:${b.spec}") bindings;
  mesg = pkgs.lib.concatMapStringsSep "    " (
    b: "alt+<u>${pkgs.lib.substring 0 1 b.label}</u>${pkgs.lib.substring 1 (-1) b.label}"
  ) bindings;
in
pkgs.writeShellScriptBin "bw-pass" ''
  export PATH=${pkgs.rofi}/bin:$PATH

  ${pkgs.rofi-rbw-wayland}/bin/rofi-rbw \
    --selector rofi --no-cache --no-help --prompt "Bitwarden" --typing-start-delay 1 --clear-after 15 \
    --keybindings "${keybindings}" \
    --selector-args="-theme $HOME/.config/rofi/config-popup.rasi -theme-str 'configuration { sort: false; }' -filter '${filter}' -mesg '${mesg}'" \
    "$@"
  status=$?

  ${pkgs.rbw}/bin/rbw stop-agent >/dev/null 2>&1
  exit $status
''
