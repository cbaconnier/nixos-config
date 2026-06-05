{ inputs, pkgs, ... }:
{
  imports = [ inputs.agenix.nixosModules.default ];
  environment.systemPackages = [ inputs.agenix.packages.${pkgs.system}.default ];
  age.identityPaths = [ "/home/clement/.ssh/id_ed25519_nixos" ];
}
