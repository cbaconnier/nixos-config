{ pkgs, lib, ... }: {

  services.systemd-lock-handler.enable = true;

  systemd.user.services.hyprlock = {
    description = "Lock the screen with hyprlock";
    partOf = [ "graphical-session.target" ];
    unitConfig.OnSuccess = [ "unlock.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = lib.getExe pkgs.hyprlock;
      Restart = "on-failure";
    };
    wantedBy = [ "lock.target" ];
  };

  security.pam.services.hyprlock = { };
}
