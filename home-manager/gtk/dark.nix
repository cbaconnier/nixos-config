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

