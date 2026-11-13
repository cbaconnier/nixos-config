{
  config,
  inputs,
  pkgs,
  ...
}:
let
  channel = "nixos-unstable";
  host = config.networking.hostName;
  rev = inputs.nixpkgs.rev;
  stateDir = "/var/lib/nixos-updates";
  cacheDir = "/var/cache/nixos-updates";

  deployed = pkgs.writeText "deployed.prom" ''
    nixos_nixpkgs_timestamp_seconds{revision="${rev}"} ${toString inputs.nixpkgs.lastModified}
  '';

  check = pkgs.writeShellApplication {
    name = "nixos-update-check";
    runtimeInputs = [
      config.nix.package
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
      pkgs.vulnix
    ];
    text = ''
      current=$(readlink -f /run/current-system)

      publish() {
        sort -u > "${stateDir}/$1.prom.tmp"
        chmod 0644 "${stateDir}/$1.prom.tmp"
        mv "${stateDir}/$1.prom.tmp" "${stateDir}/$1.prom"
      }

      cves() {
        local rc=0
        vulnix --json --closure --cache-dir "${cacheDir}/vulnix" "$2" > "${cacheDir}/$1.json" || rc=$?
        if [ "$rc" -ne 0 ] && [ "$rc" -ne 2 ]; then
          echo "vulnix failed on $2 (exit $rc)" >&2
          return 1
        fi
        jq -r --arg scope "$1" -f ${./cves.jq} "${cacheDir}/$1.json" | publish "cves-$1"
        echo "CVEs ($1): $(wc -l < "${stateDir}/cves-$1.prom")"
      }

      latest=$(curl -fsSL --retry 3 https://channels.nixos.org/${channel}/git-revision)
      available=0
      [ "$latest" != "${rev}" ] && available=1
      echo "nixos_channel_update_available{latest=\"$latest\"} $available" | publish channel

      cves current "$current"

      key="$current $latest"
      if [ "$(cat "${stateDir}/preview.key" 2> /dev/null)" = "$key" ]; then
        exit 0
      fi

      work=$(mktemp -d)
      trap 'rm -rf "$work"' EXIT
      cp -r --no-preserve=mode ${inputs.self}/. "$work"
      nix flake update --flake "path:$work"
      next=$(nix build --no-link --print-out-paths "path:$work#nixosConfigurations.${host}.config.system.build.toplevel")

      nix store diff-closures "$current" "$next" > "$work/diff"
      cat "$work/diff"
      {
        jq -rR -f ${./updates.jq} "$work/diff"
        echo "nixos_update_preview_timestamp_seconds $(date +%s)"
      } | publish preview

      cves updated "$next"
      echo "$key" > "${stateDir}/preview.key"
    '';
  };
in
{
  system.activationScripts.nixos-updates = ''
    install -Dm0644 ${deployed} ${stateDir}/deployed.prom
    rm -f ${stateDir}/cves-current.prom ${stateDir}/cves-updated.prom ${stateDir}/preview.prom ${stateDir}/preview.key
  '';

  systemd.services.nixos-update-check = {
    description = "List pending NixOS updates and CVEs";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    unitConfig.ConditionACPower = true;
    environment = {
      HOME = cacheDir;
      NO_COLOR = "1";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${check}/bin/nixos-update-check";
      StateDirectory = "nixos-updates";
      CacheDirectory = "nixos-updates";
      Nice = 19;
      IOSchedulingClass = "idle";
      TimeoutStartSec = "3h";
    };
  };

  systemd.timers.nixos-update-check = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10min";
      OnUnitActiveSec = "6h";
    };
  };

  environment.etc."alloy/nixos-updates.alloy".text = ''
    prometheus.exporter.unix "nixos_updates" {
    	set_collectors = ["textfile"]
    	textfile {
    		directory = "${stateDir}"
    	}
    }

    prometheus.scrape "nixos_updates" {
    	targets         = prometheus.exporter.unix.nixos_updates.targets
    	scrape_interval = "60s"
    	forward_to      = [prometheus.remote_write.default.receiver]
    }
  '';
}
