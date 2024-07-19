{ pkgs, lib, config, ...}:

{
 programs.rofi = {
  enable = true;
  package = pkgs.rofi-wayland;
  plugins = [ pkgs.rofi-calc ];
 
  font = "JetBrains Mono Regular 13";
  location = "center";
  terminal = "kitty";
  theme = "~/.config/rofi/themes/catppuccin-macchiato.rasi";

  extraConfig = {
   modi = "drun";
   icon-theme = "Numix-Circle";
   show-icons = true;
   disable-history = false;
   drun-display-format = "{icon} {name}";
   hide-scrollbar = true;
   display-drun = "   Apps ";
   sidebar-mode = true;
   border-radius = 10;
  };

 };

 home.file = {
  ".config/rofi/themes/catppuccin-macchiato.rasi".source = ./catppuccin-macchiato.rasi;
 };

}
