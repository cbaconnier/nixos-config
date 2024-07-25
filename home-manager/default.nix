{ pkgs, ... }:
{
 imports = [
  ./ags
  ./easyeffects
  ./git
  ./gtk
  ./hyprland
  ./kitty
  ./nvim
  ./pipewire
  ./rofi
  ./vesktop
  ./zsh
 ];

 home.packages = with pkgs; [
  geforcenow-electron
 ];

}
