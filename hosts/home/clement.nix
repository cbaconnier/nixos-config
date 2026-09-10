{
  inputs,
  pkgs,
  ...
}:

{
  home.username = "clement";
  home.homeDirectory = "/home/clement";

  imports = [
    ./../../home-manager/quickshell/home.nix
    ./../../home-manager/clipse
    ./../../home-manager/deezer
    ./../../home-manager/easyeffects
    ./../../home-manager/git
    ./../../home-manager/gtk
    ./../../home-manager/hue
    ./../../home-manager/theme
    ./../../home-manager/hyprdynamicmonitors/home.nix
    ./../../home-manager/hyprland/home.nix
    ./../../home-manager/kitty
    ./../../home-manager/mime
    ./../../home-manager/xfce4
    ./../../home-manager/nvim
    ./../../home-manager/pipewire
    ./../../home-manager/rofi
    ./../../home-manager/swayimg
    ./../../home-manager/wallpapers
    ./../../home-manager/zsh
  ];

  home.packages = with pkgs; [
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
