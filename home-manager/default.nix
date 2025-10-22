{ pkgs, ... }: {
  imports = [
    ./ags
    ./clipse
    ./easyeffects
    ./git
    ./gtk
    ./hyprland
    ./kitty
    ./mime
    ./nvim
    ./pipewire
    ./rofi
    ./tmux
    ./wallpapers
    ./zsh
  ];

  home.packages = with pkgs; [ geforcenow-electron ];

}
