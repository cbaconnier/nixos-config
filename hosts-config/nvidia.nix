{ pkgs, config, ... }:

# https://nixos.wiki/wiki/Nvidia

{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
   enable = true;
   driSupport = true;
   driSupport32Bit = true;
  };

  hardware.nvidia = {
   modesetting.enable = true;
   powerManagement.enable = false;
   powerManagement.finegrained = false;
   open = false;
   nvidiaSettings = true;
   package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
 
  xdg.portal = {
   enable = true;
   config.common.default = "*";
   extraPortals = [
     pkgs.xdg-desktop-portal-gtk
   ];
 };

}
