{
  pkgs,
  config,
  lib,
  ...
}:
let
  wallpapers_dir = "${config.home.homeDirectory}/.config/wallpapers";
  set_wallpaper_script = import ../../scripts/set-wallpaper.nix { inherit pkgs lib; };
in
{
  home.activation.set-wallpaper = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    _wp="$(${pkgs.findutils}/bin/find "${wallpapers_dir}" -maxdepth 1 -name "light.*" 2>/dev/null | ${pkgs.coreutils}/bin/head -n 1)"
    if [ -n "$_wp" ]; then
      ${set_wallpaper_script}/bin/set-wallpaper "$_wp"
    fi
  '';
}
