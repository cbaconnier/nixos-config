{ pkgs, ... }:
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

  environment.systemPackages = [ pkgs.docker-compose ];
}
