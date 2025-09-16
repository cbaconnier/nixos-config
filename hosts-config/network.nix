{ config, pkgs, ... }:

{
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking = {
    networkmanager.enable = true;

    extraHosts = ''
      127.0.0.1 host.docker.internal
      127.0.0.1 minio
    '';
  };

  #networking = {
  #  enable = true;
  #  nameservers = [ "127.0.0.1" "9.9.9.9" "149.112.112.112" ];
  #  dns = "dnsmasq";
  #};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  services.dnsmasq = {
    enable = true;
    settings = {
      server = [ "9.9.9.9" "149.112.112.112" ]; # quad9 DNS
      address = "/.test/127.0.0.1";
      listen-address = "127.0.0.1";
    };
  };

}
