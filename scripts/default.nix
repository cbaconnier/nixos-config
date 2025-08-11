{ config, pkgs, lib, inputs, ... }: {

  environment.systemPackages = [
    (import ./select-theme.nix { inherit pkgs; })
    (import ./set-wallpaper.nix { inherit pkgs lib; })
    (import ./theme.nix {
      inherit pkgs lib;
      home-manager = pkgs.home-manager;
    })
    (import ./power-menu.nix { inherit pkgs; })
    (import ./tmux-open.nix { inherit pkgs; })
  ];

}
