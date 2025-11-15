{ pkgs, ... }:

{

  # Enable nix-ld to provide dynamic libraries for non-NixOS binaries
  # This is particularly useful when developing with Electron apps and other pre-built packages

  programs.nix-ld = {
    enable = false; # Not sure I want this enabled by default

    # Libraries required by Electron and Chromium-based applications
    libraries = with pkgs; [
      # Core system libraries
      glib
      dbus
      expat

      # Graphics and rendering
      libgbm
      cairo
      pango

      # GTK and UI toolkit dependencies
      gtk3
      atk

      # X11 display server libraries
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libxcb
      libxkbcommon

      # Security and crypto
      nspr
      nss

      # Other dependencies
      cups
      alsa-lib
    ];
  };
}
