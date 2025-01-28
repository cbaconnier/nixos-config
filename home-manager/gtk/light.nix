{ pkgs, config, ... }:

# Switching between dark / light is still too experimental to make it work, and takes too long to switch ATM
# https://home-manager-options.extranix.com/?query=specialisation&release=master
# https://github.com/nix-community/home-manager/issues/4073

let
  userThemesDir = "${config.home.homeDirectory}/.local/share/themes";
  userIconsDir = "${config.home.homeDirectory}/.local/share/icons";
in {
  home.sessionVariables = {
    HYPRCURSOR_THEME = "catppuccin-latte-teal-cursors";
    HYPRCURSOR_SIZE = "24";
    XCURSOR_THEME = "catppuccin-latte-teal-cursors";
    XCURSOR_SIZE = "24";
    GTK_THEME = "catppuccin-latte-teal-standard";
    XCURSOR_PATH =
      "${config.home.homeDirectory}/.local/share/icons:${config.home.homeDirectory}/.icons:/usr/share/icons";
  };

  qt = {
    enable = true;
    platformTheme = "gtk3";
    style = {
      package = pkgs.catppuccin-kvantum;
      name = "Catppuccin-Latte-Teal";
    };
  };

  gtk = {
    enable = true;

    theme = {
      name = "catppuccin-latte-teal-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "teal" ];
        size = "standard";
        variant = "latte";
      };
    };

    cursorTheme = {
      package = pkgs.catppuccin-cursors.latteTeal;
      name = "catppuccin-latte-teal-cursors";
      size = 24;
    };

    iconTheme = {
      name = "Papirus-Light";
      package = pkgs.catppuccin-papirus-folders.override {
        accent = "teal";
        flavor = "latte";
      };
    };

    gtk3.extraConfig = { gtk-application-prefer-dark-theme = false; };

    gtk4.extraConfig = { gtk-application-prefer-dark-theme = false; };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-light";
      ### Those are pointless becase gtk set them correcty
      # cursor-size = 24;
      # cursor-theme = "catppuccin-latte-teal-cursors";
      # gtk-theme = "catppuccin-latte-teal-standard";
      # icon-theme = "Papirus-Light";
    };
  };

  #console = {
  #  earlySetup = true;
  #  colors = [
  #    "24273a"
  #    "ed8796"
  #    "a6da95"
  #    "eed49f"
  #    "8aadf4"
  #    "f5bde6"
  #    "8bd5ca"
  #    "cad3f5"
  #    "5b6078"
  #    "ed8796"
  #    "a6da95"
  #    "eed49f"
  #    "8aadf4"
  #    "f5bde6"
  #    "8bd5ca"
  #    "a5adcb"
  #  ];
  #};

  # update style without reload: https://discourse.nixos.org/t/setting-nautiilus-gtk-theme/38958/7
  xdg.configFile = {
    "gtk-4.0/assets".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    colloid-icon-theme =
      pkgs.colloid-icon-theme.override { colorVariants = [ "teal" ]; };
  };

  home.packages = with pkgs; [ numix-icon-theme-circle colloid-icon-theme ];

  # Script to make theme available system-wide
  home.activation.publish-theme =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      # Set the current specialisation name, so Hyprland will initialize it on the next boot
         run mkdir -p "$HOME/.cache"
         run echo "light" > "$HOME/.cache/.current_theme"

      # GTK Theme
         gtk_theme_path="${config.gtk.theme.package}/share/themes/catppuccin-latte-teal-standard"
         user_gtk_theme_path="${userThemesDir}/catppuccin-latte-teal-standard"
         run mkdir -p "${userThemesDir}"
         if [ ! -e "$user_gtk_theme_path" ]; then
           run ln -sf "$gtk_theme_path" "$user_gtk_theme_path"
         fi

      # Cursor Theme
         cursor_theme_path="${config.gtk.cursorTheme.package}/share/icons/catppuccin-latte-teal-cursors"
         user_cursor_theme_path="${userIconsDir}/catppuccin-latte-teal-cursors"
         default_cursor_path="${config.home.homeDirectory}/.local/share/icons/default"
         run mkdir -p "${userIconsDir}"
         if [ ! -e "$user_cursor_theme_path" ]; then
           run ln -sf "$cursor_theme_path" "$user_cursor_theme_path"
           run rm -f "$default_cursor_path"
           run ln -sf "$cursor_theme_path" "$default_cursor_path"
         fi

      ${pkgs.hyprland}/bin/hyprctl setcursor catppuccin-latte-teal-cursors 24

      # Icon Theme
         icon_theme_path="${config.gtk.iconTheme.package}/share/icons/Papirus-Light"
         user_icon_theme_path="${userIconsDir}/Papirus-Light"
         if [ ! -e "$user_icon_theme_path" ]; then
           run ln -sf "$icon_theme_path" "$user_icon_theme_path"
         fi
    '';
}

