{ lib, pkgs, ... }:

let
  # Allow a much narrower Firefox window
  userChrome = pkgs.writeText "userChrome.css" ''
    #main-window:not([popup-window]) { min-width: 250px !important; }
  '';
  userJs = pkgs.writeText "user.js" ''
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
  '';
in
{
  # Copies with write permissions into every profiles
  home.activation.firefoxProfileFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for dir in "$HOME"/.mozilla/firefox/*/; do
      [ -f "$dir/prefs.js" ] || continue
      run install -Dm644 ${userJs} "$dir/user.js"
      run install -Dm644 ${userChrome} "$dir/chrome/userChrome.css"
    done
  '';
}
