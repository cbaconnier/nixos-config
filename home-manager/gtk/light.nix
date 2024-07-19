{ pkgs, ... }:

 # Switching between dark / light is still too experimental to make it work, and takes too long to switch ATM
 # https://home-manager-options.extranix.com/?query=specialisation&release=master
 # https://github.com/nix-community/home-manager/issues/4073
 
{
  qt = {
   enable = true;
   platformTheme.name = "gtk2";
   style.name = "gtk2";
  };

  home.sessionVariables = {
   HYPRCURSOR_THEME = "catppuccin-latte-teal-cursors";
   HYPRCURSOR_SIZE = "24";
   XCURSOR_THEME = "catppuccin-latte-teal-cursors";
   XCURSOR_SIZE = "24";
   GTK_THEME = "catppuccin-latte-teal-standard";
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
 
   gtk3.extraConfig = {
     gtk-application-prefer-dark-theme = false;
   };

   gtk4.extraConfig = {
     gtk-application-prefer-dark-theme = false;
   };
  };
 
  dconf.settings = {
    "org/gnome/desktop/interface" = {
    color-scheme = "prefer-light";
   ### Those are pointless becase gtk set them correcty
   # cursor-size = 24;
   # cursor-theme = "catppuccin-latte-teal-cursors";
   # gtk-theme = "catppuccin-latte-teal-standard+normal";
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
}

