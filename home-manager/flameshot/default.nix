{ pkgs,... }:

{

 home.file = {
  ".config/flameshot/flameshot.ini".source = ./flameshot.ini;
 };

}
