{ inputs, outputs, pkgs, ... }:

{
  home.username = "clement";
  home.homeDirectory = "/home/clement";

  imports = [
    ./../../home-manager/ags
    ./../../home-manager/clipse
    ./../../home-manager/deezer
    ./../../home-manager/easyeffects
    ./../../home-manager/git
    ./../../home-manager/gtk
    ./../../home-manager/hyprdynamicmonitors/laptop.nix
    ./../../home-manager/hyprland/laptop.nix
    ./../../home-manager/kitty
    ./../../home-manager/mime
    ./../../home-manager/nvim
    ./../../home-manager/pipewire
    ./../../home-manager/rofi
    ./../../home-manager/swayimg
    ./../../home-manager/tmux
    ./../../home-manager/wallpapers
    ./../../home-manager/zsh
  ];

  home.packages = with pkgs; [ geforcenow-electron ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
  };

  # Enable the overlays.additions to access our custom pkgs in home-manager
  nixpkgs.overlays = [ outputs.overlays.additions ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}
