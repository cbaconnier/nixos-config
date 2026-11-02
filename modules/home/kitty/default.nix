{ pkgs, ... }:

# https://sw.kovidgoyal.net/kitty/conf/

let
  kittyGrab = pkgs.applyPatches {
    src = pkgs.fetchFromGitHub {
      owner = "yurikhan";
      repo = "kitty_grab";
      rev = "e115f369bcc928fa56a4f9fe935c16a2b140e43e";
      hash = "sha256-ia7plvP9872FPvbilQ6MNiFbAbIxpnzUr7bWyPuxvmI=";
    };
    patches = [ ./kitty_grab-pr44.patch ];
  };
in
{
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrains Mono Regular";
      font_size = 13;
      background_opacity = "0.95";
      cursor_trail = 1;
      cursor_trail_decay = "0.1 0.4";
      remember_window_size = "no";
      enable_audio_bell = "no";
    };

    keybindings = {
      "kitty_mod+f12" = "increase_font_size";
      "kitty_mod+f11" = "decrease_font_size";
      "kitty_mod+f10" = "reset_font_size";

      "kitty_mod+t" = "new_tab_with_cwd";
      "kitty_mod+enter" = "new_window_with_cwd";

      "kitty_mod+h" = "previous_tab";
      "kitty_mod+l" = "next_tab";
      "kitty_mod+j" = "next_window";
      "kitty_mod+k" = "previous_window";

      "kitty_mod+p" = "next_layout";

      "kitty_mod+i" = "set_window_title";

      "kitty_mod+space" = "kitten kitty_grab/grab.py";
    };
  };

  home.file = {
    ".config/kitty/kitty_grab".source = kittyGrab;
    ".config/kitty/grab.conf".source = "${kittyGrab}/grab-vim.conf.example";
    #  ".config/kitty/themes/macchiato.conf".source = ./macchiato.conf;
    ".config/kitty/themes/mocha.conf".source = ./mocha.conf;
    ".config/kitty/themes/latte.conf".source = ./latte.conf;
  };

}
