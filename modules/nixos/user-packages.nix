{ pkgs, ... }:

{
  users.users.clement = {
    packages = with pkgs; [
      # CLI
      fastfetch
      zip
      unzip
      ripgrep # run with `rg`
      jq
      yq-go # run with `yq`: yaml processor
      fzf
      file
      which
      tree
      fd # fast and user friendly alternative to `find`
      rsync
      btop
      yazi # ranger like
      lazygit
      cbonsai # Grow bonsai trees in your terminal
      speedcrunch
      nix
      home-manager
      appimage-run
      openssl
      libnotify

      # Network
      nethogs # Small 'net top' tool, grouping bandwidth by process
      ethtool # query or control network driver and hardware settings
      pciutils # PCI utilities: include `lspci`, `setpci`, `update-pciids` and `pcilmr` commands
      usbutils # USB utilities: include `lsusb`, `usb-devices` and `usbhid-dump`
      dnsutils # Network utilities: include `dig`, `nslookup` and `nsupdate`
      lsof # Tool to list open files
      speedtest-cli
      proton-vpn
      localsend
      transmission_4-gtk
      tigervnc
      wayvnc
      httpie
      insomnia
      bruno

      # Apps
      (firefox.override { extraPolicies.Certificates.Install = [ "${./caddy-root.crt}" ]; })
      (brave.override {
        commandLineArgs = "--disable-features=OutdatedBuildDetector,UseChromeOSDirectVideoDecoder,WaylandWpColorManagerV1";
      })
      discord
      teamspeak6-client
      kchat
      signal-desktop
      file-roller # Archive manager
      libreoffice
      kdePackages.okular # PDF viewer
      clipse # TUI-based clipboard manager application
      doublecmd # Double Commander
      pavucontrol
      ente-desktop
      filen-desktop
      stremio-linux-shell

      # Media
      vlc
      freetube
      spotify
      deezer-enhanced
      playerctl
      gnome-sound-recorder
      rawtherapee
      pinta
      footage # video editor
      pitivi # video editor
      ffmpeg
      imv # Image viewer, also provide `imv-dir` that auto-selects the folder where the image is located, so that the next and previous commands function works in the same way as other image viewers.
      yt-dlp # Command-line tool to download videos from YouTube.com and other sites
      poppler-utils # Adds pdfattach, pdfdetach, pdffonts, pdfimages, pdfinfo, pdfseparate, pdfsig, pdftocario, pdftohtml, pdftoppm pdftops pdftotext pdfunite
      # openshot-qt # video editor - currently insecure
      # libopenshot
      mangohud # A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more. https://wiki.archlinux.org/title/MangoHud

      # Wayland
      hyprpicker
      hyprsunset
      grim
      slurp
      satty
      rofi
      rofimoji
      wtype
      brightnessctl
      awww # Wallpaper https://codeberg.org/LGFae/awww

      # Dev
      gh
      awscli2
      github-copilot-cli
      claude-code
      gcc # C compiler
      nodejs
      python3
      cargo
      rustc
      sqlite
      mariadb.client

      # Gaming
      lutris
      wine
      mono
      gamescope
      protonup-qt
      clonehero
      prismlauncher # minecraft launcher
    ];
  };

  services = {
    gvfs.enable = true; # When installed, Thunar will show the trash can, removable media, and remote filesystems
    syncthing = {
      enable = true;
      openDefaultPorts = true;
    };

    udev.packages = [
      # Elgato Stream Deck, usable without root
      (pkgs.writeTextDir "lib/udev/rules.d/70-elgato-stream-deck.rules" ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess"
      '')

      # Logitech G560, usable without root
      (pkgs.writeTextDir "lib/udev/rules.d/70-g560.rules" ''
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0a78", TAG+="uaccess"
      '')
    ];

  };
}
