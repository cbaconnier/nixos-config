{ modulesPath, pkgs, ... }:
{
  imports = [ "${modulesPath}/virtualisation/qemu-vm.nix" ];

  networking.hostName = "playground";
  networking.nameservers = [
    "1.1.1.1"
    "9.9.9.9"
  ];
  networking.dhcpcd.extraConfig = "nohook resolv.conf";
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="52:54:00:12:34:56", NAME="net0"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="52:54:00:12:35:01", NAME="mgmt0"
  '';
  networking.dhcpcd.allowInterfaces = [ "net0" ];
  networking.interfaces.mgmt0.ipv4.addresses = [
    {
      address = "10.0.3.15";
      prefixLength = 24;
    }
  ];
  system.stateVersion = "26.05";

  virtualisation = {
    memorySize = 4096;
    cores = 2;
    diskSize = 102400;
    graphics = false;
    docker.enable = true;
    qemu.options = [
      "-monitor unix:$XDG_RUNTIME_DIR/playground-monitor.sock,server,nowait"
      "-netdev user,id=mgmt,net=10.0.3.0/24,restrict=on,hostfwd=tcp:127.0.0.1:2222-10.0.3.15:22"
      "-device virtio-net-pci,netdev=mgmt,mac=52:54:00:12:35:01"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  security.sudo.wheelNeedsPassword = false;
  users.users.runner = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG1TbGiNxBUoQPCo4j2bKa1geZIJtx5pfMD9M0W79guu claude-playground"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    rsync
    jq
    nodejs
    python3
    gnumake
    ripgrep
    fd
    tree
    file
    unzip
    lsof
    vim
  ];
}
