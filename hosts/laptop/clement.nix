{ pkgs, ... }:
{
  imports = [
    ../../modules/home/common.nix
    ../../modules/home/hyprdynamicmonitors/laptop.nix
    ../../modules/home/hypridle/laptop.nix
    ../../modules/home/hyprland/laptop.nix
    ../../modules/home/quickshell/laptop.nix
  ];

  home.packages = with pkgs; [
    amsel-suite
    kenku-fm
    amethyst-mod-manager
  ];
}
