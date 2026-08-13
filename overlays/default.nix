# This file defines overlays
{ inputs, ... }: {

  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    freetube = prev.freetube.overrideAttrs (old: rec {
      version = "0.25.2";
      src = final.fetchFromGitHub {
        owner = "FreeTubeApp";
        repo = "FreeTube";
        tag = "v${version}-beta";
        hash = "sha256-A25I64GP4FRyP21W5QuVvrWpThyU7hDosO25vkIx0UY=";
      };
      pnpmDeps = old.pnpmDeps.override {
        inherit version src;
        hash = "sha256-1OnmJi4xCxMALAac4jnLOKg5N/t3pcHgM0AgvF1+DpM=";
      };
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  nvchad = final: prev: {
    nvchad = inputs.nvchad4nix.packages.${final.system}.nvchad;
  };
}
