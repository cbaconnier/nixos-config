# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, inputs, pkgs, ... }:

{
  imports = [
     ./hardware-configuration.nix

      ./../../hosts-config/audio.nix
      ./../../hosts-config/fonts.nix
      ./../../hosts-config/greetd.nix
      ./../../hosts-config/hyprland.nix
      ./../../hosts-config/locale.nix
      ./../../hosts-config/network.nix
      ./../../hosts-config/nvidia.nix
      ./../../hosts-config/programs.nix
      ./../../hosts-config/shell.nix
      ./../../hosts-config/system-packages.nix
      ./../../hosts-config/user-packages.nix
      ./../../scripts
    ];

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

 # boot.plymouth = {
 #  enable = true;
 #  theme = "circle_hud";
 #  themePackages = [(pkgs.adi1090x-plymouth-themes.override {selected_themes = ["circle_hud"];})];
 # };

  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  networking.hostName = "home"; 

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];




  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.clement = {
    isNormalUser = true;
    description = "clement";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
