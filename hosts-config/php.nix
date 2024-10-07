{ pkgs, ... }:

# https://nixos.wiki/wiki/PHP
# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/php.section.md

{
  environment.systemPackages = with pkgs; [
    php83
    php83Packages.composer
  ];

 environment.shellInit = ''
    export PATH="$HOME/.config/composer/vendor/bin:$PATH"
  '';
}
