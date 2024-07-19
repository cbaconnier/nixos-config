{ config, pkgs, ... }: 
{

  environment.systemPackages = [
    (import ./change-theme.nix {inherit pkgs; })  
  ];

}
