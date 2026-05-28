{
  pkgs,
  config,
  ...
}:

let
  userThemesDir = "${config.home.homeDirectory}/.local/share/themes";
  userIconsDir = "${config.home.homeDirectory}/.local/share/icons";
  darkThemePkg = pkgs.catppuccin-gtk.override {
    accents = [ "blue" ];
    size = "standard";
    variant = "macchiato";
  };
  darkIconPkg = pkgs.catppuccin-papirus-folders-custom-icons (
    pkgs.catppuccin-papirus-folders.override {
      accent = "blue";
      flavor = "macchiato";
    }
  );
in
{
  qt.style = {
    package = pkgs.catppuccin-kvantum;
    name = "Catppuccin-Macchiato-Blue";
  };

  gtk.theme = {
    name = "catppuccin-macchiato-blue-standard";
    package = darkThemePkg;
  };

  gtk.iconTheme = {
    name = "Papirus-Dark";
    package = darkIconPkg;
  };

  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };

  gtk.gtk4.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "catppuccin-macchiato-blue-standard";
    icon-theme = "Papirus-Dark";
    cursor-theme = "Bibata-Modern-Ice";
    cursor-size = 24;
  };

  xdg.configFile = {
    "gtk-4.0/assets".source =
      "${darkThemePkg}/share/themes/catppuccin-macchiato-blue-standard/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source =
      "${darkThemePkg}/share/themes/catppuccin-macchiato-blue-standard/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${darkThemePkg}/share/themes/catppuccin-macchiato-blue-standard/gtk-4.0/gtk-dark.css";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    colloid-icon-theme = pkgs.colloid-icon-theme.override { colorVariants = [ "default" ]; };
  };

  home.file."${userThemesDir}/catppuccin-macchiato-blue-standard".source =
    "${darkThemePkg}/share/themes/catppuccin-macchiato-blue-standard";

  home.file."${userIconsDir}/Papirus-Dark".source = "${darkIconPkg}/share/icons/Papirus-Dark";

  home.file.".cache/.current_theme".text = "dark";

  home.file.".cache/theme-apply.sh" = {
    executable = true;
    text = ''
      ${pkgs.glib}/bin/gsettings reset org.gnome.desktop.interface gtk-theme
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme ${config.gtk.theme.name}
      ${pkgs.glib}/bin/gsettings reset org.gnome.desktop.interface color-scheme
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    '';
  };
}
