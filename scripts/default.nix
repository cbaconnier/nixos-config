{ config, pkgs, lib, inputs, ... }: 
{

  environment.systemPackages = [
    (import ./select-theme.nix {inherit pkgs; })  
    (import ./set-wallpaper.nix { inherit pkgs lib; swww = inputs.swww.packages.${pkgs.system}.swww; })  
    (import ./theme.nix { inherit pkgs lib; home-manager = pkgs.home-manager; })
    (import ./power-menu.nix {inherit pkgs; })  
  ];

}
