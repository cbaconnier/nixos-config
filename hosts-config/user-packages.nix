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
     vesktop
     lazygit
     libnotify
     clipse # TUI-based clipboard manager application


     ags # GTK widgets https://aylur.github.io/ags-docs/
     libdbusmenu-gtk3 # Library for passing menu structures across DBus, Used by AGS for the try-system
    ];
  };

# https://github.com/NixOS/nixpkgs/issues/306446#issuecomment-2081540768
 nixpkgs.overlays = [
    (final: prev:
    {
      ags = prev.ags.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ pkgs.libdbusmenu-gtk3 ];
      });
    })
  ];

  services = {
    gvfs.enable = true; # When installed, Thunar will show the trash can, removable media, and remote filesystems 
  };
}

