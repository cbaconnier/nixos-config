{ pkgs, ... }:

# https://github.com/nix-community/home-manager/issues/4073#issuecomment-2067665213

pkgs.writeShellScriptBin "select-theme" ''
    nix run 'github:fore-stun/flakes/32f0498b9dc67e9e32e57ded04ba12718d2b125b#home-manager-specialisation'
  ''
