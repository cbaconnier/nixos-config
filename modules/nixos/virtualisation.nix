{ pkgs, ... }:

# https://nixos.wiki/wiki/Docker
#

{
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
    daemon.settings = {
      log-driver = "json-file";
      log-opts = {
        tag = "{{.Name}}";
        labels-regex = "^com\\.docker\\.compose\\.(project|service)$";
        max-size = "10m";
        max-file = "3";
      };
    };
  };

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    docker-compose # start group of containers for dev
    lazydocker # TUI for docker

    qemu # Machine emulator and virtualizer
    quickemu # Quickly create and run optimised Windows, macOS and Linux virtual machines
    kubectl
    minikube
    kubernetes-helm
  ];

  #
  environment.sessionVariables = {
    # Prevent SPICE from grabbing keyboard/mouse so host shortcuts (e.g. Super+1) aren't captured by the VM window
    SPICE_NOGRAB = "1";
  };

  # QEMU built-in SMB (quickemu --public-dir)
  systemd.tmpfiles.rules = [
    "d /usr/sbin 0755 root root -"
    "L+ /usr/sbin/smbd - - - - ${pkgs.samba}/bin/smbd"
  ];

  # Starts VM Windows with KVM
  boot.extraModprobeConfig = "options kvm ignore_msrs=1";
}
