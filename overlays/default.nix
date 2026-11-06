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
      version = "0.26.0";
      src = final.fetchFromGitHub {
        owner = "FreeTubeApp";
        repo = "FreeTube";
        tag = "v${version}-beta";
        hash = "sha256-RaDpx24z3x+PfPBbPMs8ob37e+FqE6JSvDGbT827S8Q=";
      };
      pnpmDeps = old.pnpmDeps.override {
        inherit version src;
        hash = "sha256-7cxg384UNK7hIGlwxwxXpn6z8nERmb62Wb9j7MsOfbE=";
      };
    });

    # TODO(2026-09-02) Remove once https://github.com/NixOS/nixpkgs/pull/547296 is merged
    # (needed by pkgs/amethyst-mod-manager)
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (pyFinal: _pyPrev: {
        libloot = pyFinal.callPackage ../pkgs/libloot { };
      })
    ];
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  nvchad = final: prev: {
    nvchad = inputs.nvchad4nix.packages.${final.stdenv.hostPlatform.system}.nvchad;
  };
}
