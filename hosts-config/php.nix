{ pkgs, ... }:

# https://nixos.wiki/wiki/PHP

{

  environment.systemPackages = with pkgs; [
    php
    php83Packages.composer
  ];

}
