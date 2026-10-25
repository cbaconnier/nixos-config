{ pkgs, ... }:
let
  notify = pkgs.writeShellScript "remind-notify" ''
    exec ${pkgs.quickshell}/bin/qs ipc --any-display call reminders alert "$1" ""
  '';

  daemon = pkgs.writeShellScript "remind-daemon" ''
    f="$HOME/.reminders"
    touch "$f"
    ${pkgs.remind}/bin/remind -j "$f" >/dev/null && ${pkgs.gnugrep}/bin/grep -v '^#!P: Expired:' "$f.purged" > "$f.new" && mv "$f.new" "$f"
    rm -f "$f.purged" "$f.new"
    exec ${pkgs.remind}/bin/remind -z -a -a '-k${notify} %s' "$HOME/.reminders"
  '';
in
{
  home.packages = [ pkgs.remind ];

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
