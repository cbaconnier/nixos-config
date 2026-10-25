{
  pkgs,
  lib,
  config,
  ...
}:

# AMD Graphics configuration for ThinkPad Z16
# https://nixos.wiki/wiki/AMD_GPU

{
  # Enable AMD GPU support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ rocmPackages.clr.icd ];
    extraPackages32 = with pkgs; [ ];
  };

  # AMD video driver
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # XDG Portal configuration
  xdg.portal = {
    enable = true;
    config.common = {
      default = [
        "hyprland"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # System packages for AMD
  environment.systemPackages = with pkgs; [
    # Vulkan tools
    vulkan-tools
    vulkan-headers
    vulkan-loader
    vulkan-validation-layers

    # AMD-specific tools
    radeontop # GPU monitoring
    clinfo # OpenCL info
    nvtopPackages.amd
    mesa-demos
  ];
}
