{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrains Mono Regular";
      font_size = 13;
      background_opacity = "0.95";
      cursor_trail = 1;
      cursor_trail_decay = "0.1 0.4";

    };
    keybindings = {
      "kitty_mod+t" = "new_tab_with_cwd";
      "kitty_mod+enter" = "new_window_with_cwd";
      "kitty_mod+f12" = "increase_font_size";
      "kitty_mod+f11" = "decrease_font_size";
      "kitty_mod+f10" = "reset_font_size";
    };
  };

  specialisation.light.configuration = {
    programs.kitty.theme = "Catppuccin-Latte";
  };

  specialisation.dark.configuration = {
    programs.kitty.theme = "Catppuccin-Mocha";
  };

  home.file = {
    #  ".config/kitty/themes/macchiato.conf".source = ./macchiato.conf;
    ".config/kitty/themes/mocha.conf".source = ./mocha.conf;
    ".config/kitty/themes/latte.conf".source = ./latte.conf;
  };

}
