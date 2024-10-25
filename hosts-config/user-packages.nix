{ pkgs, inputs, ...}:
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
     yazi # ranger like
     libnotify
     clipse # TUI-based clipboard manager application
     rsync
     veracrypt

     grim
     slurp

     cbonsai # Grow bonsai trees in your terminal

     tigervnc
     wayvnc
     signal-desktop
     obs-studio
     spotify 

     gcc # C compiler
     nodejs


     imv # Image viewer, also provide `imv-dir` that auto-selects the folder where the image is located, so that the next and previous commands function works in the same way as other image viewers.

     ags # GTK widgets https://aylur.github.io/ags-docs/
     libdbusmenu-gtk3 # Library for passing menu structures across DBus, Used by AGS for the try-system
     home-manager  

     lutris
     wine
     gamescope

     fd # fast and user friendly alternative to `find`

     appimage-run

     inputs.swww.packages.${pkgs.system}.swww # Wallpaper https://github.com/LGFae/swww
     
     yt-dlp # Command-line tool to download videos from YouTube.com and other sites 

     nix
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

