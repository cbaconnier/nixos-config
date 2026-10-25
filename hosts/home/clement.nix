{ pkgs, ... }:
{
  imports = [
    ../../modules/home/common.nix
    ../../modules/home/hyprdynamicmonitors/home.nix
    ../../modules/home/hyprland/home.nix
    ../../modules/home/quickshell/home.nix
  ];

  home.packages = with pkgs; [
    amsel-suite
    kenku-fm
  ];
}
