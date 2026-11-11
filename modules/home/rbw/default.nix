{ lib, pkgs, ... }:

let
  pinentry = lib.getExe (import ./pinentry.nix { inherit pkgs; });
in
{
  programs.rbw.enable = true;

  home.activation.rbwConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ -r /run/agenix/rbw-email ]; then
      mkdir -p ~/.config/rbw
      ${pkgs.jq}/bin/jq -n --rawfile email /run/agenix/rbw-email \
        '{ email: ($email | rtrimstr("\n")), lock_timeout: 60, pinentry: "${pinentry}" }' \
        > ~/.config/rbw/config.json
    fi
  '';
}
