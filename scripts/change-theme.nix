{ pkgs }:

pkgs.writeShellScriptBin "change-theme" ''
    nix run 'github:fore-stun/flakes/32f0498b9dc67e9e32e57ded04ba12718d2b125b#home-manager-specialisation'
    ${pkgs.xfce.xfconf}/bin/xfconf-query --create --type string -c xsettings -p /Net/ThemeName -s "Papirus-Dark"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/cursor-theme "'catppuccin-macchiato-teal-cursors'"
  ''
