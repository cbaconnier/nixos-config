{ config, ... }:

{

  # Theme still need to be selected in the app the first time
  # But thankfully, using a symbolic link to update the theme is enough for vesktop to refresh the css

  # CSS source: https://github.com/catppuccin/discord

  home.file = {
    ".config/vesktop/themes/macchiato.conf".source =
      ./catppuccin-macchiato-blue.theme.css;
    ".config/vesktop/themes/latte.conf".source =
      ./catppuccin-latte-teal.theme.css;
  };

  specialisation.light.configuration = {
    home.activation.set-vesktop-light-theme =
      config.lib.dag.entryAfter [ "writeBoundary" ] ''
        run ln -sf \
          $HOME/.config/vesktop/themes/latte.conf \
          $HOME/.config/vesktop/themes/theme.css
      '';
  };

  specialisation.dark.configuration = {
    home.activation.set-vesktop-dark-theme =
      config.lib.dag.entryAfter [ "writeBoundary" ] ''
        run ln -sf \
          $HOME/.config/vesktop/themes/macchiato.conf \
          $HOME/.config/vesktop/themes/theme.css
      '';
  };

}
