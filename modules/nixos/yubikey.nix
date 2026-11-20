{ pkgs, ... }:
{
  # Smart card daemon, needed by ykman for the OATH, PIV and OpenPGP applets
  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    yubikey-manager # ykman: configure applets, set FIDO2 PIN, list keys
    libfido2 # fido2-token: inspect and reset the keys' FIDO2 part
  ];
}
