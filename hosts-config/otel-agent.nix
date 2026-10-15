{
  config,
  lib,
  pkgs,
  ...
}:
let
  hasSecret = builtins.pathExists ../secrets/openobserve-auth.age;
  home = "/home/clement";
  uid = "1000";
  processors = [
    "resourcedetection/system"
    "memory_limiter"
    "batch"
  ];
  levels = "DEBUG|INFO|WARN|WARNING|ERROR|CRITICAL|FATAL|TRACE";
  levelParser = pattern: {
    type = "regex_parser";
    "if" = ''body matches "${lib.replaceStrings [ "\\" ] [ "\\\\" ] pattern}"'';
    regex = pattern;
    parse_to = "attributes";
    severity.parse_from = "attributes.level";
  };
in
{
  age.secrets = lib.optionalAttrs hasSecret {
    openobserve-auth.file = ../secrets/openobserve-auth.age;
  };

  services.opentelemetry-collector = lib.mkIf hasSecret {
    enable = true;
    package = pkgs.opentelemetry-collector-contrib;
    validateConfigOverrides = [ "exporters::otlphttp/openobserve::headers::Authorization=stub" ];
    settings = {
      receivers = {
        journald.directory = "/var/log/journal";
        "filelog/docker" = {
          include = [ "${home}/.local/share/docker/containers/*/*-json.log" ];
          operators = [
            {
              type = "container";
              add_metadata_from_filepath = false;
            }
            (levelParser ''^\S+\s+(?P<level>${levels})\s'')
            (levelParser ''^\S+\s+\S+\s+(?P<level>${levels})\s'')
            (levelParser ''^(?P<level>${levels}):'')
            {
              type = "remove";
              "if" = "attributes.level != nil";
              field = "attributes.level";
            }
          ];
        };
        docker_stats = {
          endpoint = "unix:///run/user/${uid}/docker.sock";
          collection_interval = "30s";
        };
        hostmetrics = {
          collection_interval = "30s";
          scrapers = {
            cpu = { };
            load = { };
            memory = { };
            disk = { };
            filesystem = { };
            network = { };
            paging = { };
            processes = { };
          };
        };
      };

      processors = {
        "resourcedetection/system" = {
          detectors = [ "system" ];
          system.hostname_sources = [ "os" ];
        };
        memory_limiter = {
          check_interval = "1s";
          limit_percentage = 75;
          spike_limit_percentage = 15;
        };
        batch = {
          send_batch_size = 10000;
          timeout = "10s";
        };
      };

      exporters = {
        "otlphttp/openobserve" = {
          endpoint = "http://openobserve.home.arpa/api/default";
          headers.Authorization = "Basic \${env:OO_BASIC_AUTH}";
        };
        "otlphttp/openobserve_journald" = {
          endpoint = "http://openobserve.home.arpa/api/default";
          headers = {
            Authorization = "Basic \${env:OO_BASIC_AUTH}";
            stream-name = "journald";
          };
        };
      };

      service.pipelines = {
        metrics = {
          receivers = [ "hostmetrics" ];
          inherit processors;
          exporters = [ "otlphttp/openobserve" ];
        };
        "metrics/docker" = {
          receivers = [ "docker_stats" ];
          inherit processors;
          exporters = [ "otlphttp/openobserve" ];
        };
        "logs/docker" = {
          receivers = [ "filelog/docker" ];
          inherit processors;
          exporters = [ "otlphttp/openobserve" ];
        };
        "logs/journald" = {
          receivers = [ "journald" ];
          inherit processors;
          exporters = [ "otlphttp/openobserve_journald" ];
        };
      };
    };
  };

  systemd.services.opentelemetry-collector.serviceConfig = lib.mkIf hasSecret {
    DynamicUser = lib.mkForce false;
    User = "clement";
    EnvironmentFile = config.age.secrets.openobserve-auth.path;
  };
}
