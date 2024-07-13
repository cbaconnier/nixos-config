{
 inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
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
     {
     # home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.users.clement = import ./hosts/home/clement.nix;
      home-manager.extraSpecialArgs = {inherit inputs outputs; };
     }
    ];
   };
 };
}
