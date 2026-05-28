{
  pkgs,
  config,
  ...
}:

let
  userThemesDir = "${config.home.homeDirectory}/.local/share/themes";
  userIconsDir = "${config.home.homeDirectory}/.local/share/icons";
  lightThemePkg = pkgs.catppuccin-gtk.override {
    accents = [ "teal" ];
    size = "standard";
    variant = "latte";
  };
  lightIconPkg = pkgs.catppuccin-papirus-folders-custom-icons (
    pkgs.catppuccin-papirus-folders.override {
      accent = "teal";
      flavor = "latte";
    }
  );
in
{
  qt.style = {
    package = pkgs.catppuccin-kvantum;
    name = "Catppuccin-Latte-Teal";
  };

  gtk.theme = {
    name = "catppuccin-latte-teal-standard";
    package = lightThemePkg;
  };

  gtk.iconTheme = {
    name = "Papirus-Light";
    package = lightIconPkg;
  };

  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = false;
  };

  gtk.gtk4.extraConfig = {
    gtk-application-prefer-dark-theme = false;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-light";
    gtk-theme = "catppuccin-latte-teal-standard";
    icon-theme = "Papirus-Light";
    cursor-theme = "Bibata-Modern-Ice";
    cursor-size = 24;
  };

  xdg.configFile."gtk-4.0/assets".source =
    "${lightThemePkg}/share/themes/catppuccin-latte-teal-standard/gtk-4.0/assets";
  xdg.configFile."gtk-4.0/gtk.css".source =
    "${lightThemePkg}/share/themes/catppuccin-latte-teal-standard/gtk-4.0/gtk.css";
  xdg.configFile."gtk-4.0/gtk-dark.css".source =
    "${lightThemePkg}/share/themes/catppuccin-latte-teal-standard/gtk-4.0/gtk-dark.css";

  nixpkgs.config.packageOverrides = pkgs: {
    colloid-icon-theme = pkgs.colloid-icon-theme.override { colorVariants = [ "teal" ]; };
  };

  home.file.".cache/.current_theme".text = "light";

  home.file.".cache/theme-apply.sh" = {
    executable = true;
    text = ''
      ${pkgs.glib}/bin/gsettings reset org.gnome.desktop.interface gtk-theme
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme ${config.gtk.theme.name}
      ${pkgs.glib}/bin/gsettings reset org.gnome.desktop.interface color-scheme
      ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme prefer-light
    '';
  };

  home.file."${userThemesDir}/catppuccin-latte-teal-standard".source =
    "${lightThemePkg}/share/themes/catppuccin-latte-teal-standard";

  home.file."${userIconsDir}/Papirus-Light".source = "${lightIconPkg}/share/icons/Papirus-Light";
}
