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

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      portainer = {
        image = "portainer/portainer-ce:latest";
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "portainer_data:/data"
        ];
        ports = [ "9000:9000" ];
      };
    };
  };
}
