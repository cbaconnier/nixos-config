{ pkgs,... }:

{

 home.file = {
  ".config/clipse/config.json".source = ./config.json;
  ".config/clipse/custom_theme.json".source = ./custom_theme.json;
 };

}
