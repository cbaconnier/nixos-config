{ pkgs, ... }:
{
 imports = [
  ./ags
  ./easyeffects
  ./flameshot
  ./git
  ./gtk
  ./hyprland
  ./kitty
  ./nvim
  ./pipewire
  ./rofi
  ./vesktop
  ./wallpapers
  ./zsh
 ];

 home.packages = with pkgs; [
  geforcenow-electron
  flameshot-unstable
 ];

}
