{ pkgs, lib, config, ... }:

# https://nixos.wiki/wiki/Printing
#
# Bother : 
# (`everywhere`) https://github.com/OpenPrinting/cups-filters/issues/343
# (`ipp://192.168.1.29:631`) https://discourse.nixos.org/t/brother-scanner-not-detected/39953/2

{
  services.printing.enable = true;
  services.printing.drivers = [ 
    pkgs.brlaser
  ];

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Brother_MFC-L2710DW";  
        location = "Home";
        deviceUri = "ipp://192.168.1.29:631"; 
        model = "everywhere"; 
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
}
