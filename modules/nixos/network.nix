{
  config,
  lib,
  pkgs,
  ...
}:

{
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking = {
    networkmanager.enable = true;

    # open ports to cast with stremio
    # firewall.allowedTCPPorts = [
    #   11470
    #   12470
    # ];

    extraHosts = ''
      127.0.0.1 host.docker.internal
      127.0.0.1 meilisearch
      127.0.0.1 minio
      127.0.0.1 rustfs
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

  programs.ssh.startAgent = true;
  # Only shows the Quickshell "touch your YubiKey" popup, ssh asks the rest in the terminal
  programs.ssh.askPassword = "/run/current-system/sw/bin/ssh-askpass-touch";

  security.pki.certificateFiles = [ ../../files/certs/caddy-root.crt ];

  age.secrets.bento-tailscale-ip.file = ../../secrets/bento-tailscale-ip.age;
  services.dnsmasq.settings.addn-hosts = "/run/dnsmasq-bento-hosts";
  systemd.services.dnsmasq.preStart = lib.mkBefore ''
    printf '%s %s\n' "$(cat ${config.age.secrets.bento-tailscale-ip.path})" \
      "grafana.home.arpa loki.home.arpa prometheus.home.arpa syncthing.home.arpa bento-remote" \
      > /run/dnsmasq-bento-hosts
  '';

  services.dnsmasq = {
    enable = true;
    settings = {
      server = [
        "9.9.9.9"
        "149.112.112.112"
      ]; # quad9 DNS
      address = "/.test/127.0.0.1";
      listen-address = "127.0.0.1";
    };
  };

}
