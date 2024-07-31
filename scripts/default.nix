{ config, pkgs, lib, ... }: 
{

  environment.systemPackages = [
    (import ./select-theme.nix {inherit pkgs; })  
    (import ./theme.nix { inherit pkgs lib; home-manager = pkgs.home-manager; })
    (import ./power-menu.nix {inherit pkgs; })  
  ];

}
