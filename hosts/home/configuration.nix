{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/nvidia.nix
  ];

  networking.hostName = "home";

  boot.blacklistedKernelModules = [ "nouveau" ];
}
