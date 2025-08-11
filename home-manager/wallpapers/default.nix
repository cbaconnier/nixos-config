{ pkgs, config, lib, ... }:
let
  wallpapers_dir = "$HOME/.config/wallpapers";
  set_wallpaper_script =
    import ../../scripts/set-wallpaper.nix { inherit pkgs lib; };
in {

  # todo: Add default wallpapers

  specialisation.dark.configuration = {
    home.activation.set-wallpaper =
      config.lib.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.bash}/bin/bash -c '
           ${set_wallpaper_script}/bin/set-wallpaper "$(${pkgs.findutils}/bin/find ${wallpapers_dir} -name "dark.*" | ${pkgs.coreutils}/bin/head -n 1)"
        '
      '';
  };

  specialisation.light.configuration = {
    home.activation.set-wallpaper =
      config.lib.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.bash}/bin/bash -c '
           ${set_wallpaper_script}/bin/set-wallpaper "$(${pkgs.findutils}/bin/find ${wallpapers_dir} -name "light.*" | ${pkgs.coreutils}/bin/head -n 1)"
        '
      '';
  };
}
