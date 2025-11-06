{ pkgs, inputs, ... }:

{
  users.users.clement = {
    packages = with pkgs; [
      neofetch
      tmux
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
      freetube
      btop
      nvtopPackages.nvidia
      ethtool # query or control network driver and hardware settings
      pciutils # PCI utilities: include `lspci`, `setpci`, `update-pciids` and `pcilmr` commands
      usbutils # USB utilities: include `lsusb`, `usb-devices` and `usbhid-dump`
      dnsutils # Network utilities: include `dig`, `nslookup` and `nsupdate`
      firefox
      brave
      pavucontrol
      mangohud # A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more. https://wiki.archlinux.org/title/MangoHud
      hyprpicker
      discord
      kchat
      lazygit
      gh
      yazi # ranger like
      libnotify
      clipse # TUI-based clipboard manager application
      rsync
      httpie
      insomnia
      speedcrunch

      grim
      slurp
      satty

      rofi

      cbonsai # Grow bonsai trees in your terminal

      tigervnc
      wayvnc
      signal-desktop
      obs-studio
      spotify
      deezer-enhanced

      libreoffice

      gcc # C compiler
      nodejs

      cargo
      rustc

      sqlite
      mariadb-client

      rawtherapee
      pinta
      footage # video editor
      ffmpeg
      feh
      imv # Image viewer, also provide `imv-dir` that auto-selects the folder where the image is located, so that the next and previous commands function works in the same way as other image viewers.

      #ags # GTK widgets https://aylur.github.io/ags-docs/
      inputs.ags.packages.${pkgs.system}.agsFull
      libdbusmenu-gtk3 # Library for passing menu structures across DBus, Used by AGS for the system tray
      home-manager

      lutris
      wine
      gamescope
      protonup-qt

      clonehero

      prismlauncher # minecraft launcher

      fd # fast and user friendly alternative to `find`

      appimage-run

      swww # Wallpaper https://github.com/LGFae/swww

      yt-dlp # Command-line tool to download videos from YouTube.com and other sites

      nix

      ente-desktop
      filen-desktop
    ];
  };

  services = {
    gvfs.enable =
      true; # When installed, Thunar will show the trash can, removable media, and remote filesystems
    syncthing = {
      enable = true;
      openDefaultPorts = true;
    };
  };
}

