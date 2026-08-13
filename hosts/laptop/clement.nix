{
  inputs,
  pkgs,
  ...
}:

{
  home.username = "clement";
  home.homeDirectory = "/home/clement";

  imports = [
    ./../../home-manager/ags/laptop.nix
    ./../../home-manager/clipse
    ./../../home-manager/deezer
    ./../../home-manager/easyeffects
    ./../../home-manager/git
    ./../../home-manager/gtk
    ./../../home-manager/hue
    ./../../home-manager/theme
    ./../../home-manager/hyprdynamicmonitors/laptop.nix
    ./../../home-manager/hypridle/laptop.nix
    ./../../home-manager/hyprland/laptop.nix
    ./../../home-manager/hyprlock/laptop.nix
    ./../../home-manager/kitty
    ./../../home-manager/mime
    ./../../home-manager/xfce4
    ./../../home-manager/nvim
    ./../../home-manager/pipewire
    ./../../home-manager/rofi
    ./../../home-manager/swayimg
    ./../../home-manager/tmux
    ./../../home-manager/wallpapers
    ./../../home-manager/zsh
  ];

  home.packages = with pkgs; [
    geforcenow-electron
    amsel-suite
    kenku-fm
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}
