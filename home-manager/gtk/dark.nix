{ pkgs, config, ... }:

# Switching between dark / light is still too experimental to make it work, and takes too long to switch ATM
# https://home-manager-options.extranix.com/?query=specialisation&release=master
# https://github.com/nix-community/home-manager/issues/4073
let
  userThemesDir = "${config.home.homeDirectory}/.local/share/themes";
  userIconsDir = "${config.home.homeDirectory}/.local/share/icons";
in {
  home.sessionVariables = {
    HYPRCURSOR_THEME = "Bibata-Modern-Ice";
    HYPRCURSOR_SIZE = "24";
    # XCURSOR_THEME = "Bibata-Modern-Ice";
    # XCURSOR_SIZE = "24";
    GTK_THEME = "catppuccin-macchiato-blue-standard";
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style = {
      package = pkgs.catppuccin-kvantum;
      name = "Catppuccin-Macchiato-Blue";
    };
  };

  gtk = {
    enable = true;

    theme = {
      name = "catppuccin-macchiato-blue-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        variant = "macchiato";
      };
    };

    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        accent = "blue";
        flavor = "macchiato";
      };
    };

    gtk3.extraConfig = { gtk-application-prefer-dark-theme = true; };

    gtk4.extraConfig = { gtk-application-prefer-dark-theme = true; };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      ### Those are pointless becase gtk set them correcty
      # cursor-size = 24;
      # cursor-theme = "catppuccin-macchiato-blue-cursors";
      # gtk-theme = "catppuccin-macchiato-blue-standard";
      # icon-theme = "Papirus-Dark";
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
      pkgs.colloid-icon-theme.override { colorVariants = [ "default" ]; };
  };

  home.packages = with pkgs; [
    numix-icon-theme-circle
    colloid-icon-theme
    bibata-cursors
  ];

  home.file.".icons/default".source =
    "${config.gtk.cursorTheme.package}/share/icons/Bibata-Modern-Ice";

  home.file.".icons/Bibata-Modern-Ice".source =
    "${config.gtk.cursorTheme.package}/share/icons/Bibata-Modern-Ice";

  # Script to make theme available system-wide
  home.activation.publish-theme =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      # Set the current specialisation name, so Hyprland will initialize it on the next boot
         run mkdir -p "$HOME/.cache"
         run echo "dark" > "$HOME/.cache/.current_theme"

      # GTK Theme
         gtk_theme_path="${config.gtk.theme.package}/share/themes/catppuccin-macchiato-blue-standard"
         user_gtk_theme_path="${userThemesDir}/catppuccin-macchiato-blue-standard"
         run mkdir -p "${userThemesDir}"
         if [ ! -e "$user_gtk_theme_path" ]; then
           run ln -sf "$gtk_theme_path" "$user_gtk_theme_path"
         fi

      # Cursor Theme
         cursor_theme_path="${config.gtk.cursorTheme.package}/share/icons/Bibata-Modern-Ice"
         user_cursor_theme_path="${userIconsDir}/Bibata-Modern-Ice"
         run mkdir -p "${userIconsDir}"
         if [ ! -e "$user_cursor_theme_path" ]; then
           run ln -sf "$cursor_theme_path" "$user_cursor_theme_path"
         fi

        ${pkgs.hyprland}/bin/hyprctl setcursor Bibata-Modern-Ice 24

      # Icon Theme
         icon_theme_path="${config.gtk.iconTheme.package}/share/icons/Papirus-Dark"
         user_icon_theme_path="${userIconsDir}/Papirus-Dark"
         if [ ! -e "$user_icon_theme_path" ]; then
           run ln -sf "$icon_theme_path" "$user_icon_theme_path"
         fi
    '';
}
