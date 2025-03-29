{ pkgs, inputs, ... }:
let
  ags = pkgs.ags_1.overrideAttrs
    (_: prev: { buildInputs = prev.buildInputs ++ [ pkgs.libdbusmenu-gtk3 ]; });
in {
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
      ethtool # query or control network driver and hardware settings
      pciutils # PCI utilities: include `lspci`, `setpci`, `update-pciids` and `pcilmr` commands
      usbutils # USB utilities: include `lsusb`, `usb-devices` and `usbhid-dump`
      dnsutils # Network utilities: include `dig`, `nslookup` and `nsupdate`
      firefox
      pavucontrol
      mangohud # A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more. https://wiki.archlinux.org/title/MangoHud
      hyprpicker
      discord
      lazygit
      gh
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
      parsec-bin

      libreoffice

      gcc # C compiler
      nodejs

      cargo
      rustc

      sqlite
      mariadb-client

      imv # Image viewer, also provide `imv-dir` that auto-selects the folder where the image is located, so that the next and previous commands function works in the same way as other image viewers.

      ags # GTK widgets https://aylur.github.io/ags-docs/
      libdbusmenu-gtk3 # Library for passing menu structures across DBus, Used by AGS for the system tray
      home-manager

      lutris
      wine
      gamescope
      protonup-qt

      prismlauncher # minecraft launcher

      fd # fast and user friendly alternative to `find`

      appimage-run

      inputs.swww.packages.${pkgs.system}.swww # Wallpaper https://github.com/LGFae/swww

      yt-dlp # Command-line tool to download videos from YouTube.com and other sites

      nix
    ];
  };

  # https://github.com/NixOS/nixpkgs/issues/306446#issuecomment-2081540768
  nixpkgs.overlays = [
    (final: prev: {
      ags = prev.ags.overrideAttrs
        (old: { buildInputs = old.buildInputs ++ [ pkgs.libdbusmenu-gtk3 ]; });

      freetube = prev.freetube.overrideAttrs (old:
        let
          _src = prev.fetchFromGitHub {
            owner = "FreeTubeApp";
            repo = "FreeTube";
            tag = "v0.23.3-beta";
            hash = "sha256-EpcYNUtGbEFvetroo1zAyfKxW70vD1Lk0aJKWcaV39I=";
          };
        in {
          version = "0.23.3";
          src = _src;

          yarnOfflineCache = prev.fetchYarnDeps {
            yarnLock = "${_src}/yarn.lock";
            hash = "sha256-xiJGzvmfrvvB6/rdwALOxhWSWAZ31cbySYygtG8+QpQ=";
          };
        });
    })
  ];

  services = {
    gvfs.enable =
      true; # When installed, Thunar will show the trash can, removable media, and remote filesystems
    syncthing = {
      enable = true;
      openDefaultPorts = true;
    };
  };
}

