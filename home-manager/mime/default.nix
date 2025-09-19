{ pkgs, ... }:

let
  feh-wrapper = pkgs.writeShellScript "feh-wrapper" ''
    #!/bin/sh
    feh --theme default --start-at "$1" "$(dirname "$1")"
  '';
in {

  xdg.desktopEntries = {
    feh-custom = {
      name = "feh";
      exec = "${feh-wrapper} %f";
      mimeType = [
        "image/jpeg"
        "image/png"
        "image/gif"
        "image/bmp"
        "image/tiff"
        "image/webp"
      ];
      noDisplay = true;
    };

    nvim-terminal = {
      name = "neovim";
      exec = "kitty nvim %F";
      mimeType = [ "text/plain" "text/x-csrc" "application/json" ];
      noDisplay = true;
      terminal = false;
    };
  };

  # xdg.mimeApps = {
  #   enable = true;
  #   defaultApplications = {
  #     "inode/directory" = [ "Thunar.desktop" ];
  #
  #     "image/jpeg" = [ "feh-custom.desktop" ];
  #     "image/png" = [ "feh-custom.desktop" ];
  #     "image/gif" = [ "feh-custom.desktop" ];
  #     "image/bmp" = [ "feh-custom.desktop" ];
  #     "image/tiff" = [ "feh-custom.desktop" ];
  #     "image/webp" = [ "feh-custom.desktop" ];
  #
  #     "x-scheme-handler/http" = [ "firefox.desktop" ];
  #     "x-scheme-handler/https" = [ "firefox.desktop" ];
  #     "x-scheme-handler/chrome" = [ "firefox.desktop" ];
  #     "text/html" = [ "firefox.desktop" ];
  #     "application/x-extension-htm" = [ "firefox.desktop" ];
  #     "application/x-extension-html" = [ "firefox.desktop" ];
  #     "application/x-extension-shtml" = [ "firefox.desktop" ];
  #     "application/xhtml+xml" = [ "firefox.desktop" ];
  #     "application/x-extension-xhtml" = [ "firefox.desktop" ];
  #     "application/x-extension-xht" = [ "firefox.desktop" ];
  #   };
  #   associations.added = {
  #     "x-scheme-handler/http" = "firefox.desktop";
  #     "x-scheme-handler/https" = "firefox.desktop";
  #     "x-scheme-handler/chrome" = "firefox.desktop";
  #     "text/html" = "firefox.desktop";
  #     "application/x-extension-htm" = "firefox.desktop";
  #     "application/x-extension-html" = "firefox.desktop";
  #     "application/x-extension-shtml" = "firefox.desktop";
  #     "application/xhtml+xml" = "firefox.desktop";
  #     "application/x-extension-xhtml" = "firefox.desktop";
  #     "application/x-extension-xht" = "firefox.desktop";
  #   };
  # };
}
