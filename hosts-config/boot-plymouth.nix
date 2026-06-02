{ inputs, pkgs, ... }:
{
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_level=3"
  ];

  boot.initrd.enable = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.compressor = "gzip";

  boot.plymouth = {
    enable = true;
    theme = "cat";
    themePackages = [ inputs.plymouth-theme-cat.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  };
}
