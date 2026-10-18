{ pkgs, ... }:
let
  notify = pkgs.writeShellScript "remind-notify" ''
    exec ${pkgs.quickshell}/bin/qs ipc call reminders alert "$1" ""
  '';

  daemon = pkgs.writeShellScript "remind-daemon" ''
    touch "$HOME/.reminders"
    exec ${pkgs.remind}/bin/remind -z -a -a '-k${notify} %s' "$HOME/.reminders"
  '';
in
{
  # Not on PATH as `remind`: it would shadow the countdown script in scripts/remind.nix.
  home.packages = [
    (pkgs.runCommand "remind-cli" { } ''
      mkdir -p $out/bin
      ln -s ${pkgs.remind}/bin/remind $out/bin/remind-cli
    '')
  ];

  systemd.user.services.remind = {
    Unit.Description = "remind daemon";
    Service = {
      ExecStart = "${daemon}";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
