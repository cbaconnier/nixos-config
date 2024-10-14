{ pkgs, inputs, ...}: 
{
  
  # This file enable the development version when stable one get unstable
  # You first need to uncomment the file in configuration.nix
  # You also need to disable (`enable=false`) hyprland in home-manager

  # https://wiki.hyprland.org/Nix/Hyprland-on-NixOS/

  # https://wiki.hyprland.org/Nix/Cachix/
  nix.settings = {
   substituters = ["https://hyprland.cachix.org"];
   trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="]; 
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland; # xdphls
  	xwayland.enable = true;
  };

  # Hint electron apps to use wayland:
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
