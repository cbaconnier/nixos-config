{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # https://wiki.hyprland.org/Nix/Hyprland-on-NixOS/

  # https://wiki.hyprland.org/Nix/Cachix/
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    withUWSM = false;
    xwayland.enable = true;
  };

  # https://github.com/NixOS/nixpkgs/issues/573049
  # TODO(2026-10-25): remove once the hyprland flake ships a binary wrapper
  security.wrappers.Hyprland.source = lib.mkForce "${config.programs.hyprland.package}/bin/.Hyprland-wrapped";
  environment.systemPackages = [
    inputs.hyprland.inputs.hyprland-guiutils.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # https://wiki.hyprland.org/Nix/Hyprland-on-NixOS/
  hardware.graphics =
    let
      hyprPkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      package = hyprPkgs.mesa;
      package32 = hyprPkgs.pkgsi686Linux.mesa;
    };

  # Hint electron apps to use wayland:
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
