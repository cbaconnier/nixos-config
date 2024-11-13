{ pkgs, ...}:
{
 programs = {

  thunar = {
   enable = true;
   plugins = with pkgs.xfce; [
    exo  #Open Terminal Here
    mousepad
    thunar-archive-plugin
    thunar-volman #  Automatic management of removeable devices in Thunar.
    tumbler # External program to generate thumbnails.
   ];
  };

  # Enable archives action on thunar.
  # todo: use xarchiver instead, but couldn't make it work
  file-roller = { 
    enable = true;
  };

  # Running steam game with gamescope (Steam Deck Virtual Desktop)
  # https://github.com/sonic2kk/steamtinkerlaunch/wiki/GameScope
  # https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1229444338

  #https://nixos.wiki/wiki/Steam
  steam = {
   enable = true;
   remotePlay.openFirewall = true;
   dedicatedServer.openFirewall = true;
  };


  # Gamemode is a daemon and library combo for Linux that allows games to request a set of optimisations be temporarily applied to the host OS and/or a game process. 
  # https://wiki.archlinux.org/title/gamemode
  # On steam games you would use it this way: gamemoderun %command%
  gamemode.enable = true;   

  # dconf is a low-level configuration system for storing application settings.
  # Enabling it allows GNOME and other applications to store and retrieve configuration data.
  dconf.enable = true;

  xfconf.enable = true;

 };
}
