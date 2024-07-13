{ pkgs, ... }:

{
 home.packages = with pkgs; [
 ];

 programs.git = {
  enable = true;
  userName = "Clément Baconnier";
  userEmail = "clement@baconnier.ch";  
 };

}
