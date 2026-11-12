{ config, pkgs, ... }:
let
  lokiDir = "/var/lib/loki";
  sizesDir = "/var/lib/stack-sizes";
  dropinDir = "/var/lib/grafana-dashboards";
in
{
  systemd.tmpfiles.rules = [ "d ${dropinDir} 0755 clement users -" ];

  age.secrets = {
    grafana-env = {
      file = ../../../secrets/grafana-env.age;
      owner = "grafana";
    };
    caddy-ingest.file = ../../../secrets/caddy-ingest.age;
  };

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = 3100;
        grpc_listen_address = "127.0.0.1";
        grpc_listen_port = 9096;
        log_level = "warn";
      };
      common = {
        instance_addr = "127.0.0.1";
        path_prefix = lokiDir;
        storage.filesystem = {
          chunks_directory = "${lokiDir}/chunks";
          rules_directory = "${lokiDir}/rules";
        };
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };
      schema_config.configs = [
        {
          from = "2020-10-24";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
      limits_config = {
        retention_period = "720h";
        split_queries_by_interval = "24h";
        max_query_parallelism = 32;
      };
      compactor = {
        working_directory = "${lokiDir}/retention";
        retention_enabled = true;
        delete_request_store = "filesystem";
      };
      analytics.reporting_enabled = false;
    };
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9090;
    retentionTime = "30d";
    extraFlags = [ "--web.enable-remote-write-receiver" ];
    globalConfig.scrape_interval = "30s";
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [ { targets = [ "localhost:9090" ]; } ];
      }
      {
        job_name = "loki";
        static_configs = [ { targets = [ "localhost:3100" ]; } ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        root_url = "https://grafana.home.arpa";
      };
      security.secret_key = "$__env{GF_SECURITY_SECRET_KEY}";
      users.allow_sign_up = false;
      analytics = {
        reporting_enabled = false;
        check_for_updates = false;
      };
      "unified_alerting.state_history" = {
        enabled = true;
        backend = "loki";
        loki_remote_url = "http://127.0.0.1:3100";
      };
    };
    provision = {
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:9090";
            uid = "prometheus";
            isDefault = true;
          }
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:3100";
            uid = "loki";
          }
        ];
      };
      dashboards.settings = {
        apiVersion = 1;
        providers = [
          {
            name = "default";
            type = "file";
            disableDeletion = false;
            allowUiUpdates = false;
            options = {
              path = ./dashboards;
              foldersFromFilesStructure = true;
            };
          }
          {
            name = "dropin";
            type = "file";
            allowUiUpdates = false;
            options = {
              path = dropinDir;
              foldersFromFilesStructure = true;
            };
          }
        ];
      };
      alerting = {
        contactPoints.path = ./alerting/contactpoints.yaml;
        policies.path = ./alerting/policies.yaml;
        rules.path = ./alerting/rules.yaml;
        templates.path = ./alerting/templates.yaml;
      };
    };
  };
  systemd.services.grafana.serviceConfig.EnvironmentFile = config.age.secrets.grafana-env.path;

  services.caddy = {
    enable = true;
    globalConfig = "skip_install_trust";
    virtualHosts = {
      "grafana.home.arpa" = {
        logFormat = "output stderr";
        extraConfig = ''
          tls internal
          reverse_proxy 127.0.0.1:3000
        '';
      };
      "loki.home.arpa".logFormat = "output discard";
      "prometheus.home.arpa".logFormat = "output discard";
      "loki.home.arpa".extraConfig = ''
        tls internal
        basic_auth {
          {$INGEST_USER} {$INGEST_HASH}
        }
        reverse_proxy 127.0.0.1:3100
      '';
      "prometheus.home.arpa".extraConfig = ''
        tls internal
        basic_auth {
          {$INGEST_USER} {$INGEST_HASH}
        }
        reverse_proxy 127.0.0.1:9090
      '';
    };
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets.caddy-ingest.path;

  networking.firewall.allowedTCPPorts = [ 443 ];

  environment.etc."alloy/volumes.alloy".text = ''
    prometheus.exporter.unix "volumes" {
    	set_collectors = ["textfile"]
    	textfile {
    		directory = "${sizesDir}"
    	}
    }

    prometheus.scrape "volumes" {
    	targets         = prometheus.exporter.unix.volumes.targets
    	scrape_interval = "60s"
    	forward_to      = [prometheus.remote_write.default.receiver]
    }
  '';

  systemd.services.stack-sizes = {
    description = "Measure the monitoring stack's data sizes";
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "stack-sizes";
    };
    path = [ pkgs.coreutils ];
    script = ''
      out=${sizesDir}/volumes.prom
      size() {
        local bytes
        bytes=$(du -sb "$2" 2> /dev/null | cut -f1) || return 0
        [ -n "$bytes" ] && echo "stack_volume_bytes{service=\"$1\"} $bytes"
        return 0
      }
      {
        echo "# TYPE stack_volume_bytes gauge"
        size loki ${lokiDir}
        size prometheus /var/lib/${config.services.prometheus.stateDir}
      } > "$out.tmp"
      chmod 0644 "$out.tmp"
      mv "$out.tmp" "$out"
    '';
  };
  systemd.timers.stack-sizes = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "5min";
    };
  };
}
