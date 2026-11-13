{ ... }:
{
  imports = [ ../../modules/home/claude ];

  home.username = "clement";
  home.homeDirectory = "/home/clement";

  programs.home-manager.enable = true;

  home.stateVersion = "26.05";
}
