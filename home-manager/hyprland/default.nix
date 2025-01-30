{ pkgs, config, lib, inputs, ... }:

# Note: HYPRCURSOR_THEME and HYPRCURSOR_SIZE are defined in /home-manager/gtk/default.nix
#
# https://nixos.wiki/wiki/Hyprland#Using_Home_Manager

{
  wayland.windowManager.hyprland = {
    enable = true;
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;

    extraConfig = ''
      $path = $HOME/.config/hypr

      $mainMod = SUPER

      source=$path/monitors.conf
      source=$path/workspaces.conf
      source=$path/windows.conf
      source=$path/startup_apps.conf
      source=$path/keybinds.conf
      source=$path/behavior.conf
      source=$path/input.conf
    '';

    #plugins = [ inputs.hy3.packages.x86_64-linux.hy3 ];
    # disabled because it will start with the login manager
    # also it causes conflicts with our config
    systemd.enable = false;
  };

  # https://wiki.hyprland.org/Hypr-Ecosystem/
  home.packages = with pkgs; [ wl-clipboard hyprcursor ];

  home.file = {
    #  ".config/hypr/hyprland.conf".source = ./hyprland.conf;
    ".config/hypr/keybinds.conf".source = ./keybinds.conf;
    ".config/hypr/workspaces.conf".source = ./workspaces.conf;
    ".config/hypr/monitors.conf".source = ./monitors.conf;
    ".config/hypr/behavior.conf".source = ./behavior.conf;
    ".config/hypr/windows.conf".source = ./windows.conf;
    ".config/hypr/input.conf".source = ./input.conf;
    ".config/hypr/startup_apps.conf".source = ./startup_apps.conf;
  };
}
