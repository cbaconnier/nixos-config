{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    yubikey-manager # ykman: configure applets, set FIDO2 PIN, list keys
    libfido2 # fido2-token: inspect and reset the keys' FIDO2 part
  ];

  # Empty ssh-agent when a YubiKey is unplugged
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="hidraw", ENV{ID_FIDO_TOKEN}=="1", ATTRS{idVendor}=="1050", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="yubikey-unplug@%k.service"
  '';

  systemd.user.services."yubikey-unplug@" = {
    description = "Empty ssh-agent when YubiKey %I is unplugged";
    unitConfig = {
      BindsTo = "dev-%i.device";
      After = "dev-%i.device";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "SSH_AUTH_SOCK=%t/ssh-agent";
      ExecStop = "-${pkgs.openssh}/bin/ssh-add -D";
    };
  };
}
