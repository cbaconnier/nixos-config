{ pkgs, config, lib, inputs, ... }:

# Note: HYPRCURSOR_THEME and HYPRCURSOR_SIZE are defined in /home-manager/gtk/default.nix
#
# https://nixos.wiki/wiki/Hyprland#Using_Home_Manager

{
  wayland.systemd.target = "default.target";

  wayland.windowManager.hyprland = {
    enable = true;
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;

    configType = "lua";

    # Split config modules. Each is written under ~/.config/hypr and auto
    # require()d (in alphabetical order) from the generated hyprland.lua.
    extraLuaFiles = {
      app_keybinds = ./app_keybinds.lua;
      behavior = ./behavior.lua;
      input = ./input.lua;
      keybinds = ./keybinds.lua;
      startup_apps = ./laptop/startup_apps.lua;
      windows = ./windows.lua;
    };

    # Load the runtime monitors/workspaces written by HyprDynamicMonitors. The
    # file may not exist yet on first start (before the daemon runs), so guard
    # it. dofile (not require) re-executes it when the daemon rewrites the file
    # and triggers a reload.
    extraConfig = ''
      do
        local monitorsFile = os.getenv("HOME") .. "/.config/hypr/config.d/monitors.lua"
        local f = io.open(monitorsFile, "r")
        if f then
          f:close()
          dofile(monitorsFile)
        end
      end
    '';

    # disabled because it will start with the login manager
    # also it causes conflicts with our config
    systemd.enable = false;
  };

  # https://wiki.hyprland.org/Hypr-Ecosystem/
  home.packages = with pkgs; [ wl-clipboard hyprcursor wtype ];

  # Create the config.d directory for HyprDynamicMonitors
  home.file.".config/hypr/config.d/.keep".text = "";
}
