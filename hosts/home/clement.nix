{ config, inputs, pkgs, ...}:

{
 home.username = "clement";
 home.homeDirectory = "/home/clement";

 imports = [
  ./../../home-manager
 ];


 home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";


    #I'm experimenting thoses. I haven't encountered any issue without them though
    GBM_BACKEND= "nvidia-drm";           # Use NVIDIA DRM for buffer management
    __GLX_VENDOR_LIBRARY_NAME= "nvidia"; # Force the use of NVIDIA's GLX library
    LIBVA_DRIVER_NAME= "nvidia";         # Use NVIDIA for hardware acceleration
    __GL_VRR_ALLOWED="1";                # Enable Variable Refresh Rate if available
    WLR_NO_HARDWARE_CURSORS = "1";       # Disable hardware cursors 
    WLR_RENDERER_ALLOW_SOFTWARE = "1";   # Allow software rendering as fallback
    CLUTTER_BACKEND = "wayland";         # Use Wayland backend for Clutter
    WLR_RENDERER = "gles2";              # Use OpenGL as the renderer for wlroots (`vulkan` is not supported by Hyprland)

    XDG_CURRENT_DESKTOP = "Hyprland";    # Set the current desktop environment
    XDG_SESSION_DESKTOP = "Hyprland";    # Set the desktop session
    XDG_SESSION_TYPE = "wayland";        # Specify the session type as Wayland
 };


 
 home.stateVersion = "24.11";
 programs.home-manager.enable = true;

}
