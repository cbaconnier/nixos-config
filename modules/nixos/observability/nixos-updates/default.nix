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

      # Drop the preview if it was made for another system, so a failed run
      # doesn't leave it on the dashboard.
      key=$(cat "${stateDir}/preview.key" 2> /dev/null || true)
      if [ "''${key%% *}" != "$current" ]; then
        rm -f "${stateDir}/preview.prom" "${stateDir}/cves-updated.prom" "${stateDir}/preview.key"
      fi

      cves current "$current"

      work=$(mktemp -d)
      trap 'rm -rf "$work"' EXIT
      cp -r --no-preserve=mode ${inputs.self}/. "$work"
      # Pin nixpkgs to the channel revision so the preview matches the update flag.
      nix flake update --flake "path:$work" --override-input nixpkgs "github:NixOS/nixpkgs/$latest"

      key="$current $(sha256sum < "$work/flake.lock" | cut -d' ' -f1)"
      if [ "$(cat "${stateDir}/preview.key" 2> /dev/null)" = "$key" ]; then
        exit 0
      fi

      # Keep the result out of the garbage collector for the next check and upgrade.
      next=$(nix build --out-link "${cacheDir}/next" --print-out-paths "path:$work#nixosConfigurations.${host}.config.system.build.toplevel")

      nix store diff-closures "$current" "$next" > "$work/diff"
      cat "$work/diff"
      jq -cR -f ${./parse.jq} "$work/diff" > "$work/packages.json"
      names=$(jq -sc 'map(.package) | unique' "$work/packages.json")
      changelogs=$(nix eval --json "path:$work#nixosConfigurations.${host}.pkgs" --apply "pkgs:
        builtins.listToAttrs (map (n:
          let r = builtins.tryEval (pkgs.\''${n}.meta.changelog or \"\");
          in { name = n; value = if r.success && builtins.isString r.value then r.value else \"\"; }
        ) (builtins.fromJSON '''$names'''))" || echo '{}')
      {
        jq -r --argjson changelogs "$changelogs" -f ${./updates.jq} "$work/packages.json"
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
  '';

  # Refresh Grafana after each config change
  systemd.services.nixos-update-check-trigger = {
    description = "Queue nixos-update-check after a configuration switch";
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ inputs.self.outPath ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.systemd.package}/bin/systemctl start --no-block nixos-update-check.service";
    };
  };

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
      # The trigger unit already runs the check at boot.
      OnBootSec = "6h";
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
