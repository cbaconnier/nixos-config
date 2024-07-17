{ pkgs }:

pkgs.writeShellScriptBin "change-theme" ''
    nix run 'github:fore-stun/flakes/32f0498b9dc67e9e32e57ded04ba12718d2b125b#home-manager-specialisation'
  ''
