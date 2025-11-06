# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, inputs, pkgs, services, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./../../hosts-config/audio.nix
    ./../../hosts-config/virtualisation.nix
    ./../../hosts-config/fonts.nix
    ./../../hosts-config/glib.nix
    ./../../hosts-config/greetd.nix
    ./../../hosts-config/hyprland.nix
    ./../../hosts-config/laptop-amd.nix
    ./../../hosts-config/laptop-power.nix
    ./../../hosts-config/locale.nix
    ./../../hosts-config/network.nix
    ./../../hosts-config/php.nix
    ./../../hosts-config/printer.nix
    ./../../hosts-config/programs.nix
    ./../../hosts-config/proxy.nix
    ./../../hosts-config/shell.nix
    ./../../hosts-config/system-packages.nix
    ./../../hosts-config/user-packages.nix
    ./../../scripts
  ];

  # specifics for the laptop
  programs.nm-applet.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Limit the number of generations to keep
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.timeout = 2;

  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" ];
  boot.initrd.enable = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.compressor = "gzip";

  boot.plymouth = {
    enable = true;
    theme = "circle_hud";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override {
        selected_themes = [ "circle_hud" ];
      })
    ];
  };

  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  networking.hostName = "melba";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.clement = {
    isNormalUser = true;
    description = "clement";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ networkmanagerapplet ];
  };

  systemd.services.home-manager-clement = {
    serviceConfig = { RemainAfterExit = "yes"; };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
