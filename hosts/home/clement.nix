{ inputs, outputs, pkgs, ... }:

{
  home.username = "clement";
  home.homeDirectory = "/home/clement";

  imports = [
    ./../../home-manager/ags
    ./../../home-manager/clipse
    ./../../home-manager/deezer
    ./../../home-manager/easyeffects
    ./../../home-manager/git
    ./../../home-manager/gtk
    ./../../home-manager/hyprdynamicmonitors/home.nix
    ./../../home-manager/hyprland/home.nix
    ./../../home-manager/kitty
    ./../../home-manager/mime
    ./../../home-manager/nvim
    ./../../home-manager/pipewire
    ./../../home-manager/rofi
    ./../../home-manager/swayimg
    ./../../home-manager/tmux
    ./../../home-manager/wallpapers
    ./../../home-manager/zsh
  ];

  home.packages = with pkgs; [ geforcenow-electron ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";

    #I'm experimenting thoses. I haven't encountered any issue without them though
    GBM_BACKEND = "nvidia-drm"; # Use NVIDIA DRM for buffer management
    __GLX_VENDOR_LIBRARY_NAME =
      "nvidia"; # Force the use of NVIDIA's GLX library
    LIBVA_DRIVER_NAME = "nvidia"; # Use NVIDIA for hardware acceleration
    __GL_VRR_ALLOWED = "1"; # Enable Variable Refresh Rate if available
    # WLR_NO_HARDWARE_CURSORS = "1";       # Disable hardware cursors 
    WLR_RENDERER_ALLOW_SOFTWARE = "1"; # Allow software rendering as fallback
    CLUTTER_BACKEND = "wayland"; # Use Wayland backend for Clutter
    WLR_RENDERER =
      "gles2"; # Use OpenGL as the renderer for wlroots (`vulkan` is not supported by Hyprland)

    XDG_CURRENT_DESKTOP = "Hyprland"; # Set the current desktop environment
    XDG_SESSION_DESKTOP = "Hyprland"; # Set the desktop session
    XDG_SESSION_TYPE = "wayland"; # Specify the session type as Wayland
  };

  # Enable the overlays.additions to access our custom pkgs in home-manager
  nixpkgs.overlays = [ outputs.overlays.additions ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}
