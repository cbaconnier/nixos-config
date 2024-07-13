{
 inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
 };

 outputs =  { self, nixpkgs, home-manager, ... }@inputs: {
  nixosConfigurations.home = nixpkgs.lib.nixosSystem {
   specialArgs = { inherit inputs; };
   system = "x86_64-linux";
   modules = [
    ./hosts/home/configuration.nix
    home-manager.nixosModules.home-manager
    {
     home-manager.useGlobalPkgs = true;
     home-manager.useUserPackages = true;
     home-manager.backupFileExtension = "backup";
     home-manager.users.clement = import ./hosts/home/clement.nix;
    }
   ];
  };
 };
}
