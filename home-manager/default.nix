{ pkgs, ... }: {
  imports = [
    ./ags
    ./clipse
    ./easyeffects
    ./flameshot
    ./git
    ./gtk
    ./hyprland
    ./kitty
    ./nvim
    ./pipewire
    ./rofi
    ./tmux
    ./wallpapers
    ./zsh
  ];

  home.packages = with pkgs; [
    ente-photos
    geforcenow-electron
    flameshot-unstable
  ];

}
