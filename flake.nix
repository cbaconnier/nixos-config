{
  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland?submodules=2&ref=v0.56.1";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    astal.url = "github:aylur/astal";

    hyprdynamicmonitors.url = "github:fiffeek/hyprdynamicmonitors";

    plymouth-theme-cat.url = "github:cbaconnier/PlymouthTheme-Cat";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      inherit (self) outputs;
      mkHost =
        host:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/${host}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.clement = import ./hosts/${host}/clement.nix;
              home-manager.extraSpecialArgs = { inherit inputs outputs; };
            }
          ];
        };
    in
    {

      overlays = import ./overlays { inherit inputs; };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

      nixosConfigurations = nixpkgs.lib.genAttrs [ "home" "laptop" ] mkHost;
    };
}
