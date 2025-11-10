{ pkgs, lib, config, ... }:

# https://nixos.wiki/wiki/Nvidia

{

  environment.systemPackages = with pkgs; [
    vulkan-tools
    vulkan-headers
    vulkan-loader
    vulkan-validation-layers
    nvtopPackages.nvidia
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    #driSupport = true;
    #driSupport32Bit = true;
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #  version = "555.58";
    #  sha256_64bit = "sha256-bXvcXkg2kQZuCNKRZM5QoTaTjF4l2TtrsKUvyicj5ew=";
    #  sha256_aarch64 = lib.fakeSha256;
    #  openSha256 = lib.fakeSha256;
    #  settingsSha256 = "sha256-vWnrXlBCb3K5uVkDFmJDVq51wrCoqgPF03lSjZOuU8M=";
    #  persistencedSha256 = lib.fakeSha256;
    # };
  };

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      # pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # Fix: DRM kernel driver 'nvidia-drm' in use. NVK requires nouveau 
  # The error has been seen when running lutris
  # environment.variables = {
  #    VK_ICD_FILENAMES = "${config.hardware.nvidia.package}/share/vulkan/icd.d/nvidia_icd.x86_64.json";
  # };
}
