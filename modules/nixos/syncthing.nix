{
  # Devices and folders are managed from the web UI (https://syncthing.home.arpa),
  # so don't let the module wipe them on rebuild.
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    overrideDevices = false;
    overrideFolders = false;
  };

  services.caddy.virtualHosts."syncthing.home.arpa" = {
    logFormat = "output discard";
    extraConfig = ''
      tls internal
      reverse_proxy 127.0.0.1:8384 {
        header_up Host {upstream_hostport}
      }
    '';
  };
}
