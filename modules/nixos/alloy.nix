{
  config,
  lib,
  ...
}:
let
  hasSecret = builtins.pathExists ../../secrets/alloy-ingest.age;
in
{
  age.secrets = lib.optionalAttrs hasSecret {
    alloy-ingest.file = ../../secrets/alloy-ingest.age;
  };

  environment.etc."alloy/config.alloy".source = ./alloy/config.alloy;

  services.alloy = lib.mkIf hasSecret {
    enable = true;
    environmentFile = config.age.secrets.alloy-ingest.path;
    extraFlags = [ "--disable-reporting" ];
  };

  systemd.services.alloy = lib.mkIf hasSecret {
    environment = {
      LOKI_URL = "https://loki.home.arpa/loki/api/v1/push";
      PROM_URL = "https://prometheus.home.arpa/api/v1/write";
      JOURNAL_PATH = "/var/log/journal";
      DOCKER_SOCK = "unix:///run/user/1000/docker.sock";
      CONTAINERD_SOCK = "/run/user/1000/docker/containerd/containerd.sock";
      # alloy links systemd-minimal-libs, which cannot read zstd-compressed journals
      LD_PRELOAD = "${config.systemd.package}/lib/libsystemd.so.0";
    };
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "clement";
    };
  };
}
