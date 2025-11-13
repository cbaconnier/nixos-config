{ pkgs, lib, config, ... }:

# https://nixos.wiki/wiki/Printing
#
# Bother : 
# (`everywhere`) https://github.com/OpenPrinting/cups-filters/issues/343
# (`ipp://192.168.1.29:631`) https://discourse.nixos.org/t/brother-scanner-not-detected/39953/2

# Setup printers: http://localhost:631
# Direct printing: lp -d ipp://192.168.1.xx:631/ipp/print document.pdf
# Temporary add a printer: sudo lpadmin -p printerName -v ipp://192.168.1.xx:631 -E

# Use `lpq` or `lpstat -o` to check print queue
# Use `cancel <job-id>` to cancel a job

{
  services.printing = {
    enable = true;
    browsed.enable =
      false; # Disable browsed daemon to prevent CUPS vulnerability
    # drivers = [ 
    #   pkgs.brlaser
    # ];
  };

  # Allow nixos to build when printer is offline
  # https://github.com/NixOS/nixpkgs/issues/78535#issuecomment-2200268221
  services.printing.drivers = lib.singleton (pkgs.linkFarm "drivers" [{
    name = "share/cups/model/Brother_MFC-L2710DW.ppd";
    path = ../printers/Brother_MFC-L2710DW.ppd;
  }]);

  hardware.printers = {
    ensurePrinters = [{
      name = "Brother_MFC-L2710DW";
      location = "Home";
      deviceUri = "ipp://192.168.1.29:631";
      model = "Brother_MFC-L2710DW.ppd";
      ppdOptions = { PageSize = "A4"; };
    }];
    ensureDefaultPrinter = "Brother_MFC-L2710DW";
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  users.users.clement = { packages = with pkgs; [ system-config-printer ]; };

}
