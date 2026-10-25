{ ... }:
{
  imports = [
    ./clipse
    ./deezer
    ./easyeffects
    ./firefox
    ./git
    ./gtk
    ./hue
    ./hyprlock
    ./kitty
    ./mime
    ./nvim
    ./pipewire
    ./reminders
    ./rofi
    ./swayimg
    ./theme
    ./wallpapers
    ./xfce4
    ./zsh
  ];

  home.username = "clement";
  home.homeDirectory = "/home/clement";

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}
