{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/agenix.nix
    ../../modules/nixos/alloy.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/tailscale.nix
  ];

  networking.hostName = "bento";
  networking.networkmanager.enable = true;
  networking.extraHosts = ''
    100.116.221.46 grafana.home.arpa loki.home.arpa prometheus.home.arpa
  '';

  security.pki.certificateFiles = [ ../../files/certs/caddy-root.crt ];

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
  };

  zramSwap.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  users.users.clement = {
    isNormalUser = true;
    description = "clement";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFNZrnn3toGnHv4HjEUzfGU1xQuTJTccvtY8RxsV6R6o default"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  environment.systemPackages = with pkgs; [
    claude-code
    git
    tmux
    vim
    curl
    jq
    ripgrep
    fd
    tree
    htop
  ];

  system.stateVersion = "26.05";
}
