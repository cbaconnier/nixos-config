{
  # specialisation,
  pkgs,
  config,
  ...
}:

# specialisation.dark.configuration = { imports = [ ./dark.nix ]; };

# specialisation.light.configuration = { imports = [ ./light.nix ]; };

let
  userThemesDir = "${config.home.homeDirectory}/.local/share/themes";
  userIconsDir = "${config.home.homeDirectory}/.local/share/icons";
in
{
  home.sessionVariables = {
    HYPRCURSOR_THEME = "Bibata-Modern-Ice";
    HYPRCURSOR_SIZE = "24";
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
      package = pkgs.catppuccin-papirus-folders-custom-icons (
        pkgs.catppuccin-papirus-folders.override {
          accent = "blue";
          flavor = "macchiato";
        }
      );
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # Update style without reload: https://discourse.nixos.org/t/setting-nautiilus-gtk-theme/38958/7
  xdg.configFile = {
    "gtk-4.0/assets".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    colloid-icon-theme = pkgs.colloid-icon-theme.override { colorVariants = [ "default" ]; };
  };

  home.packages = with pkgs; [
    numix-icon-theme-circle
    colloid-icon-theme
    bibata-cursors
  ];

  # Cursor theme symlinks for system-wide availability
  home.file.".icons/default".source =
    "${config.gtk.cursorTheme.package}/share/icons/Bibata-Modern-Ice";

  home.file.".icons/Bibata-Modern-Ice".source =
    "${config.gtk.cursorTheme.package}/share/icons/Bibata-Modern-Ice";

  # GTK Theme symlink for system-wide availability
  home.file."${userThemesDir}/catppuccin-macchiato-blue-standard".source =
    "${config.gtk.theme.package}/share/themes/catppuccin-macchiato-blue-standard";

  # Cursor Theme symlink for system-wide availability
  home.file."${userIconsDir}/Bibata-Modern-Ice".source =
    "${config.gtk.cursorTheme.package}/share/icons/Bibata-Modern-Ice";

  # Icon Theme symlink for system-wide availability
  home.file."${userIconsDir}/Papirus-Dark".source =
    "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark";

  # Cache file to track current theme (if needed by other scripts)
  home.file.".cache/.current_theme".text = "dark";
}
