# https://github.com/Misterio77/nix-starter-configs/blob/main/standard/flake.nix

{
 inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
 };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    #nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    #homeManagerModules = import ./home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # home is my hostname
      home = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/home/configuration.nix
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "clement@home" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/home/clement.nix
        ];
      };
    };
  };


# # nixosConfigurations.home = nixpkgs.lib.nixosSystem {
#
#
#
#   specialArgs = { inherit inputs; };
#   system = "x86_64-linux";
#   modules = [
#    ./hosts/home/configuration.nix
#    home-manager.nixosModules.home-manager
#    {
#     home-manager.useGlobalPkgs = true;
#     home-manager.useUserPackages = true;
#     home-manager.backupFileExtension = "backup";
#     home-manager.users.clement = import ./hosts/home/clement.nix;
#    }
#   ];
#  };
# };
}
