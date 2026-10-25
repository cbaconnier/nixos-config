{ outputs, pkgs, ... }:
{
  imports = [
    ./agenix.nix
    ./alloy.nix
    ./audio.nix
    ./boot-plymouth.nix
    ./flatpak.nix
    ./fonts.nix
    ./glib.nix
    ./greetd.nix
    ./hue.nix
    ./hyprland.nix
    ./locale.nix
    ./network.nix
    ./nix-ld.nix
    ./php.nix
    ./printer.nix
    ./programs.nix
    ./screen-lock.nix
    ./shell.nix
    ./system-packages.nix
    ./tailscale.nix
    ./user-packages.nix
    ./virtualisation.nix
    ../../scripts
  ];

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    timeout = 2;
    efi.canTouchEfiVariables = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
  ];

  users.users.clement = {
    isNormalUser = true;
    description = "clement";
    extraGroups = [
      "networkmanager"
      "wheel"
      "gamemode"
    ];
  };

  systemd.services.home-manager-clement.serviceConfig.RemainAfterExit = "yes";

  system.stateVersion = "24.05";
}
