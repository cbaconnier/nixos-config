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
      version = "0.25.3";
      src = final.fetchFromGitHub {
        owner = "FreeTubeApp";
        repo = "FreeTube";
        tag = "v${version}-beta";
        hash = "sha256-eaf10W8dBMJDlqOFd57hsqQqRcBOYAMavLrfmkuRbSw=";
      };
      pnpmDeps = old.pnpmDeps.override {
        inherit version src;
        hash = "sha256-rsgDxK6X2EzgPwIb9A9I+STkKI882i8jDuL4pO5kJHU=";
      };
    });

    glasscope = final.callPackage ../pkgs/glasscope {
      hyprland = inputs.hyprland.packages.${final.system}.hyprland;
    };
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
