{
  pkgs,
  config,
  ...
}:

let
  userIconsDir = "${config.home.homeDirectory}/.local/share/icons";
in
{
  home.sessionVariables = {
    HYPRCURSOR_THEME = "Bibata-Modern-Ice";
    HYPRCURSOR_SIZE = "24";
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    gtk4.theme = null;
  };

  home.packages = with pkgs; [
    numix-icon-theme-circle
    colloid-icon-theme
    bibata-cursors
  ];

  home.file.".icons/default".source =
    "${config.gtk.cursorTheme.package}/share/icons/Bibata-Modern-Ice";

  home.file.".icons/Bibata-Modern-Ice".source =
    "${config.gtk.cursorTheme.package}/share/icons/Bibata-Modern-Ice";

  home.file."${userIconsDir}/Bibata-Modern-Ice".source =
    "${config.gtk.cursorTheme.package}/share/icons/Bibata-Modern-Ice";
}
