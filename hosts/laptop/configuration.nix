{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/laptop-amd.nix
    ../../modules/nixos/laptop-power.nix
    ../../modules/nixos/virtual-voices
  ];

  networking.hostName = "laptop";

  programs.nm-applet.enable = true;

  users.users.clement.packages = with pkgs; [
    networkmanagerapplet
    wdisplays
  ];

  boot.kernelParams = [
    # https://discourse.nixos.org/t/external-mouse-and-keyboard-sleep-when-they-stay-untouched-for-a-few-seconds/14900/11
    "usbcore.autosuspend=-1"
    "resume=/dev/disk/by-uuid/4b7e06e2-7ff3-44e3-8767-4c1c1d198726"
    "resume_offset=384231424"
  ];
  boot.resumeDevice = "/dev/disk/by-uuid/4b7e06e2-7ff3-44e3-8767-4c1c1d198726";

  boot.initrd = {
    availableKernelModules = [
      "typec"
      "typec_ucsi"
      "ucsi_acpi"
      "typec_displayport"
    ];
    kernelModules = [
      "amdgpu"
    ];
  };
}
