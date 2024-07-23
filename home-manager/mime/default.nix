{ pkgs, ...}:
{
  xdg.mime.enable = false;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = ["Thunar.desktop"];
      "image/png" = ["imv-dir"];
      "image/jpeg" = ["imv-dir"];
    };
  };

  xdg.mimeApps = let x = "firefox.desktop"; in {
    defaultApplications = let f = [x]; in {
      "x-scheme-handler/http" = f;
      "x-scheme-handler/https" = f;
      "x-scheme-handler/chrome" = f;
      "text/html" = f;
      "application/x-extension-htm" = f;
      "application/x-extension-html" = f;
      "application/x-extension-shtml" = f;
      "application/xhtml+xml" = f;
      "application/x-extension-xhtml" = f;
      "application/x-extension-xht" = f;
    };
    associations.added = let f = x; in {
      "x-scheme-handler/http" = f;
      "x-scheme-handler/https" = f;
      "x-scheme-handler/chrome" = f;
      "text/html" = f;
      "application/x-extension-htm" = f;
      "application/x-extension-html" = f;
      "application/x-extension-shtml" = f;
      "application/xhtml+xml" = f;
      "application/x-extension-xhtml" = f;
      "application/x-extension-xht" = f;
    };
  };
}
