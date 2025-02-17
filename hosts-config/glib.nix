{ pkgs, lib, ... }: {
  services.dbus.packages = [ pkgs.dconf ];

  environment.systemPackages = with pkgs; [
    glib
    gsettings-desktop-schemas
    bibata-cursors
  ];

  environment.sessionVariables = {
    GSETTINGS_SCHEMA_DIR =
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";

    # XCURSOR_PATH = lib.mkForce
    #   "/run/current-system/sw/share/icons:$HOME/.icons:$HOME/.local/share/icons";

    XCURSOR_PATH = lib.mkForce
      "/run/current-system/sw/share/icons:$HOME/.icons:$HOME/.local/share/icons";

    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = 24;
  };
}
