{ pkgs, ... }:

# https://nixos.wiki/wiki/Docker
#
# https://nixos.wiki/wiki/NixOS_Containers#Declarative_docker_containers
# https://search.nixos.org/options?query=virtualisation.oci-containers
#

{
  virtualisation.containers.enable = true;

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      #dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    docker-compose # start group of containers for dev
    #podman-compose # start group of containers for dev
  ];

}
