# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
   noise-suppression-for-voice = pkgs.callPackage ./noise-suppression-for-voice { };
}
