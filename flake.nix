{
  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland?submodules=1&ref=v0.51.1";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    astal.url = "github:aylur/astal";

    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
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
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.clement = import ./hosts/home/clement.nix;
            home-manager.extraSpecialArgs = { inherit inputs outputs; };
          }
        ];
      };
    };
}
