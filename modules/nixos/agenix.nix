{ inputs, pkgs, ... }:
{
  imports = [ inputs.agenix.nixosModules.default ];
  environment.systemPackages = [ inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
