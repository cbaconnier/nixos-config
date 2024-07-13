{ pkgs, ...}:

{
 programs.kitty = {
  enable = true;
  settings = {
   font_family = "JetBrains Mono Regular";
   font_size = 13;
   background_opacity = "0.95";
  };
  theme = "Catppuccin-Mocha";
 };

 home.file = {
#  ".config/kitty/themes/macchiato.conf".source = ./macchiato.conf;
  ".config/kitty/themes/mocha.conf".source = ./mocha.conf;
 };

}
