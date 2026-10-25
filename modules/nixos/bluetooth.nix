{ config, pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    blueman # GTK-based Bluetooth Manager
    bluez # Official Linux Bluetooth protocol stack
    bluez-tools # Set of tools to manage bluetooth devices for linux
  ];
}
