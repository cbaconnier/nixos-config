{ pkgs, lib, config, ... }:

# https://nixos.wiki/wiki/Printing
#
# Bother : 
# (`everywhere`) https://github.com/OpenPrinting/cups-filters/issues/343
# (`ipp://192.168.1.29:631`) https://discourse.nixos.org/t/brother-scanner-not-detected/39953/2

{
  services.printing = {
    enable = true;
    # drivers = [ 
    #   pkgs.brlaser
    # ];
  };

  # Allow nixos to build when printer is offline
  # https://github.com/NixOS/nixpkgs/issues/78535#issuecomment-2200268221
  services.printing.drivers = lib.singleton (pkgs.linkFarm "drivers" [
    { 
      name = "share/cups/model/Brother_MFC-L2710DW.ppd";
      path = ../printers/Brother_MFC-L2710DW.ppd;
    }
  ]);


  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_MFC-L2710DW";  
        location = "Home";
        deviceUri = "ipp://192.168.1.29:631"; 
        model = "Brother_MFC-L2710DW.ppd"; 
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "Brother_MFC-L2710DW";
  };


 services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Prevent CUPS vulnerability 
  systemd.services.cup-browsed.enable = false;
}
