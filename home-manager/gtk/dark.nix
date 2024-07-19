{ pkgs, config, ... }:

 # Switching between dark / light is still too experimental to make it work, and takes too long to switch ATM
 # https://home-manager-options.extranix.com/?query=specialisation&release=master
 # https://github.com/nix-community/home-manager/issues/4073
 let
  userThemesDir = "${config.home.homeDirectory}/.local/share/themes";
  userIconsDir = "${config.home.homeDirectory}/.local/share/icons";
in
{
  qt = {
   enable = true;
   platformTheme.name = "gtk2";
   style.name = "gtk2";
  };

  home.sessionVariables = {
   HYPRCURSOR_THEME = "catppuccin-macchiato-teal-cursors";
   HYPRCURSOR_SIZE = "24";
   XCURSOR_THEME = "catppuccin-macchiato-teal-cursors";
   XCURSOR_SIZE = "24";
   GTK_THEME = "catppuccin-macchiato-teal-standard";
  };
 
  gtk = {
   enable = true;
   
   theme = {
    name = "catppuccin-macchiato-teal-standard";
    package = pkgs.catppuccin-gtk.override {
     accents = [ "teal" ];
     size = "standard";
     variant = "macchiato";
    };
   };
 
   cursorTheme = {
    package = pkgs.catppuccin-cursors.macchiatoTeal;
    name = "catppuccin-macchiato-teal-cursors";
    size = 24;
   };
 
   iconTheme = {
    name = "Papirus-Dark";
    package = pkgs.catppuccin-papirus-folders.override {
      accent = "teal";       
      flavor = "macchiato";
    };
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
   ### Those are pointless becase gtk set them correcty
   # cursor-size = 24;
   # cursor-theme = "catppuccin-macchiato-teal-cursors";
   # gtk-theme = "catppuccin-macchiato-teal-standard";
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
  "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
  "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
  "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
 };
       
 nixpkgs.config.packageOverrides = pkgs: {
   colloid-icon-theme = pkgs.colloid-icon-theme.override { colorVariants = ["teal"]; };
 };
  
  home.packages = with pkgs; [
   numix-icon-theme-circle
   colloid-icon-theme
   catppuccin-kvantum
 
   # gnome.gnome-tweaks
   # gnome.gnome-shell
   # gnome.gnome-shell-extensions
   # xsettingsd
   # themechanger
 ];

 # Script to make theme available system-wide
home.activation.publish-theme = config.lib.dag.entryAfter ["writeBoundary"] ''
 # Set the current specialisation name, so Hyprland will initialize it on the next boot
    $DRY_RUN_CMD mkdir -p "$HOME/.cache"
    $DRY_RUN_CMD echo "dark" > "$HOME/.cache/.current_theme"

 # GTK Theme
    gtk_theme_path="${config.gtk.theme.package}/share/themes/catppuccin-macchiato-teal-standard"
    user_gtk_theme_path="${userThemesDir}/catppuccin-macchiato-teal-standard"
    $DRY_RUN_CMD mkdir -p "${userThemesDir}"
    if [ ! -e "$user_gtk_theme_path" ]; then
      $DRY_RUN_CMD ln -sf "$gtk_theme_path" "$user_gtk_theme_path"
    fi

 # Cursor Theme
    cursor_theme_path="${config.gtk.cursorTheme.package}/share/icons/catppuccin-macchiato-teal-cursors"
    user_cursor_theme_path="${userIconsDir}/catppuccin-macchiato-teal-cursors"
    $DRY_RUN_CMD mkdir -p "${userIconsDir}"
    if [ ! -e "$user_cursor_theme_path" ]; then
      $DRY_RUN_CMD ln -sf "$cursor_theme_path" "$user_cursor_theme_path"
    fi

 # Icon Theme
    icon_theme_path="${config.gtk.iconTheme.package}/share/icons/Papirus-Dark"
    user_icon_theme_path="${userIconsDir}/Papirus-Dark"
    if [ ! -e "$user_icon_theme_path" ]; then
      $DRY_RUN_CMD ln -sf "$icon_theme_path" "$user_icon_theme_path"
    fi
    '';

}

