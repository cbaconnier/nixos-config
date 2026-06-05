{ pkgs, lib, ... }: {
  home.packages = [ pkgs.hue-bridge-tui ];

  home.activation.huecli-setup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f /run/agenix/hue-api-key ]; then
      mkdir -p $HOME/.config/huecli
      cat /run/agenix/hue-api-key > $HOME/.config/huecli/userinfo.txt
    fi
  '';
}
