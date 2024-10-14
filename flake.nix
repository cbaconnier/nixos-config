{
 inputs = {

  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  hyprland.url = "github:hyprwm/Hyprland?submodules=1&ref=v0.44.1&submodules=1";
  swww.url = "github:LGFae/swww";
  #hy3 = {
  #  url = "github:outfoxxed/hy3?ref=hl0.41.2"; 
  #  inputs.hyprland.follows = "hyprland"; 
  #};
 };

 outputs =  { self, nixpkgs, home-manager, ... }@inputs: 
  let 
   system = "x86_64-linux";
   pkgs = nixpkgs.legacyPackages.${system}; 
   inherit (self) outputs;
  in {

   overlays = import ./overlays { inherit inputs; };

   nixosConfigurations.home = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs outputs; };
    modules = [
     ./hosts/home/configuration.nix
     home-manager.nixosModules.home-manager
    # hyprland.homeManagerModules.default
     {
     # home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.clement = import ./hosts/home/clement.nix;
      home-manager.extraSpecialArgs = {inherit inputs outputs; };

      #wayland.windowManager.hyprland.plugins = [ hy3.packages.x86_64-linux.hy3 ];
     }
    ];
   };
 };
}
