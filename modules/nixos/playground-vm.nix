{
  config,
  lib,
  outputs,
  pkgs,
  ...
}:
let
  cfg = config.programs.playground;
  vm = outputs.nixosConfigurations.playground.config.system.build.vm;

  user = "clement";
  home = config.users.users.${user}.home;
  uid = if config.users.users.${user}.uid == null then 1000 else config.users.users.${user}.uid;
  stateDir = "${home}/.local/state/playground";

  nft = "${pkgs.nftables}/bin/nft";
  cgroup = "system.slice/playground-vm.service";

  rules = pkgs.writeText "playground-vm.nft" ''
    table inet playground_vm {
      chain out {
        type filter hook output priority 0; policy accept;
        socket cgroupv2 level 2 "${cgroup}" ct state established,related accept
        socket cgroupv2 level 2 "${cgroup}" ip daddr { 10.0.0.0/8, 100.64.0.0/10, 127.0.0.0/8, 169.254.0.0/16, 172.16.0.0/12, 192.168.0.0/16 } reject
        socket cgroupv2 level 2 "${cgroup}" ip6 daddr { ::1, fc00::/7, fe80::/10, fec0::/10 } reject
      }
    }
  '';

  fwStart = pkgs.writeShellScript "playground-fw-start" ''
    set -eu
    ${nft} delete table inet playground_vm 2>/dev/null || true
    ${nft} -f ${rules}
  '';

  netOff = pkgs.writeShellScript "playground-net-off" ''
    set -euo pipefail
    sock="$XDG_RUNTIME_DIR/playground-monitor.sock"
    for i in $(${pkgs.coreutils}/bin/seq 1 50); do
      [ -S "$sock" ] && break
      ${pkgs.coreutils}/bin/sleep 0.2
    done
    [ -S "$sock" ]
    out=$({ printf 'set_link virtio-net-pci.0 off\n'; ${pkgs.coreutils}/bin/sleep 0.3; } \
      | ${pkgs.socat}/bin/socat - "UNIX-CONNECT:$sock")
    if printf '%s' "$out" | ${pkgs.gnugrep}/bin/grep -qiE 'not found|error'; then
      exit 1
    fi
    echo off > "$XDG_RUNTIME_DIR/playground-net"
  '';
in
{
  options.programs.playground.enable = lib.mkEnableOption "the playground VM and the playground command";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ (import ../../scripts/playground.nix { inherit pkgs; }) ];

    systemd.services.playground-vm = {
      description = "Playground VM";
      environment = {
        NIX_DISK_IMAGE = "${stateDir}/disk.qcow2";
        XDG_RUNTIME_DIR = "/run/user/${toString uid}";
      };
      serviceConfig = {
        User = user;
        Group = "users";
        ExecStartPre = [
          "+${fwStart}"
          "${pkgs.coreutils}/bin/rm -f /run/user/${toString uid}/playground-monitor.sock"
          "${pkgs.coreutils}/bin/mkdir -p ${stateDir}"
        ];
        ExecStart = "${vm}/bin/run-playground-vm";
        ExecStartPost = netOff;
        ExecStopPost = "-+${nft} delete table inet playground_vm";
      };
    };

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "playground-vm.service" &&
            subject.user == "${user}") {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
