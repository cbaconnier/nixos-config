{ pkgs, lib, config, ... }:

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

  # Environment variables for AMD
  environment.variables = {
    # Force AMDVLK instead of RADV for Vulkan
    # Comment out if you prefer RADV (Mesa's Vulkan driver)
    # VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json";

    # For ROCm applications
    # HSA_OVERRIDE_GFX_VERSION = "10.3.0"; # Adjust based on your GPU
  };

  # XDG Portal configuration
  xdg.portal = {
    enable = true;
    config.common.default = "*";
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      # pkgs.xdg-desktop-portal-hyprland
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
