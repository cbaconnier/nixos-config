{ pkgs, ... }:

# https://nixos.wiki/wiki/Docker
#
# https://nixos.wiki/wiki/NixOS_Containers#Declarative_docker_containers
# https://search.nixos.org/options?query=virtualisation.oci-containers
#

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    autoPrune.enable = true;
  };

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

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      portainer = {
        image = "portainer/portainer-ce:latest";
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "portainer_data:/data"
        ];
        ports = [ "9002:9000" ];
      };
    };
  };
}
