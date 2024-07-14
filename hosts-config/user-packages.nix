{ pkgs, ...}:
{
  users.users.clement = {
    packages = with pkgs; [ 
     neofetch
     zip
     unzip
     ripgrep # run with `rg`
     jq
     yq-go # run with `yq`: yaml processor
     fzf
     file
     which
     tree
     vlc
     btop
     ethtool # query or control network driver and hardware settings
     pciutils # PCI utilities: include `lspci`, `setpci`, `update-pciids` and `pcilmr` commands
     usbutils # USB utilities: include `lsusb`, `usb-devices` and `usbhid-dump`
     firefox
     pavucontrol
     mangohud # A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more. https://wiki.archlinux.org/title/MangoHud
     hyprpicker
     xboxdrv # xbox controller driver
     webcord
     lazygit
     clipse # TUI-based clipboard manager application
    ];
  };

  services = {
    gvfs.enable = true; # When installed, Thunar will show the trash can, removable media, and remote filesystems 
  };
}

