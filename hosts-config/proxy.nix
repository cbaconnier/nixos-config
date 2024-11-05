{ pkgs, inputs, config, lib, ...}:
{
  users.users.clement = {
    packages = with pkgs; [ 
      mitmproxy
    ];
  };

  security.pki.certificateFiles = lib.optionals 
      # you may want to run sudo cp ~/.mitmproxy/mitmproxy-ca-cert.pem /etc/ssl/certs/mitmproxy-ca-cert.pem 
      # I hav'nt find a way to do it automatically
    (builtins.pathExists "/etc/nixos/certs/mitmproxy-ca-cert.pem")
    [ "/etc/nixos/certs/mitmproxy-ca-cert.pem" ];
}
