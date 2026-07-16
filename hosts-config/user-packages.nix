{ pkgs, inputs, ... }:

{
  users.users.clement = {
    packages = with pkgs; [
      fastfetch
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
      file-roller # Archive manager
      freetube
      btop
      nethogs # Small 'net top' tool, grouping bandwidth by process
      ethtool # query or control network driver and hardware settings
      pciutils # PCI utilities: include `lspci`, `setpci`, `update-pciids` and `pcilmr` commands
      usbutils # USB utilities: include `lsusb`, `usb-devices` and `usbhid-dump`
      dnsutils # Network utilities: include `dig`, `nslookup` and `nsupdate`
      lsof # Tool to list open files
      firefox
      brave
      pavucontrol
      mangohud # A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more. https://wiki.archlinux.org/title/MangoHud
      hyprpicker
      discord
      teamspeak6-client
      gnome-sound-recorder
      kchat
      lazygit
      gh
      github-copilot-cli
      claude-code
      yazi # ranger like
      libnotify
      clipse # TUI-based clipboard manager application
      rsync
      localsend
      httpie
      insomnia
      bruno
      speedcrunch
      speedtest-cli
      proton-vpn
      transmission_4-gtk

      grim
      slurp
      satty

      rofi

      cbonsai # Grow bonsai trees in your terminal

      tigervnc
      wayvnc
      signal-desktop
      spotify
      deezer-enhanced
      playerctl
      brightnessctl
      alarm-clock-applet

      libreoffice
      kdePackages.okular # PDF viewer

      gcc # C compiler
      nodejs
      python3

      openssl

      cargo
      rustc

      sqlite
      mariadb.client

      rawtherapee
      pinta
      footage # video editor
      # openshot-qt # video editor - currently insecure
      libopenshot
      pitivi # video editor
      ffmpeg

      imv # Image viewer, also provide `imv-dir` that auto-selects the folder where the image is located, so that the next and previous commands function works in the same way as other image viewers.

      poppler-utils # Adds pdfattach, pdfdetach, pdffonts, pdfimages, pdfinfo, pdfseparate, pdfsig, pdftocario, pdftohtml, pdftoppm pdftops pdftotext pdfunite

      inputs.ags.packages.${pkgs.stdenv.hostPlatform.system}.agsFull
      libdbusmenu-gtk3 # Library for passing menu structures across DBus, Used by AGS for the system tray
      home-manager

      # lutris
      # TODO: remove override when openldap is fixed
      (lutris.override {
        # Intercept buildFHSEnv to modify target packages
        buildFHSEnv =
          args:
          pkgs.buildFHSEnv (
            args
            // {
              multiPkgs =
                envPkgs:
                let
                  # Fetch original package list
                  originalPkgs = args.multiPkgs envPkgs;

                  # Disable tests for openldap
                  customLdap = envPkgs.openldap.overrideAttrs (_: {
                    doCheck = false;
                  });
                in
                # Replace broken openldap with the custom one
                builtins.filter (p: (p.pname or "") != "openldap") originalPkgs ++ [ customLdap ];
            }
          );
      })
      wine
      mono
      gamescope
      protonup-qt

      clonehero

      prismlauncher # minecraft launcher

      fd # fast and user friendly alternative to `find`

      appimage-run

      awww # Wallpaper https://codeberg.org/LGFae/awww

      yt-dlp # Command-line tool to download videos from YouTube.com and other sites

      nix

      ente-desktop
      filen-desktop
    ];
  };

  services = {
    gvfs.enable = true; # When installed, Thunar will show the trash can, removable media, and remote filesystems
    syncthing = {
      enable = true;
      openDefaultPorts = true;
    };
  };
}
