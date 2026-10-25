# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'

pkgs: {
  noise-suppression-for-voice = pkgs.callPackage ./noise-suppression-for-voice { };
  amsel-suite = pkgs.callPackage ./amsel-suite { };
  kenku-fm = pkgs.callPackage ./kenku-fm { };
  amethyst-mod-manager = pkgs.callPackage ./amethyst-mod-manager { };
}
