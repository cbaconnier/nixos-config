{ pkgs, lib, config, ... }:

{
  programs.rofi = {
    enable = true;
    plugins = [ pkgs.rofi-calc ];

    font = "JetBrains Mono Regular 13";
    location = "center";
    terminal = "kitty";

    extraConfig = {
      modi = "drun";
      icon-theme = "Numix-Circle";
      show-icons = true;
      disable-history = false;
      drun-display-format = "{icon} {name}";
      hide-scrollbar = true;
      display-drun = "   Apps ";
      sidebar-mode = true;
      border-radius = 10;
    };

  };

  specialisation.light.configuration = {
    programs.rofi.theme = "~/.config/rofi/themes/catppuccin-latte.rasi";
  };

  specialisation.dark.configuration = {
    programs.rofi.theme = "~/.config/rofi/themes/catppuccin-macchiato.rasi";
  };

  home.file = {
    ".config/rofi/themes/catppuccin-macchiato.rasi".source =
      ./catppuccin-macchiato.rasi;
    ".config/rofi/themes/catppuccin-latte.rasi".source =
      ./catppuccin-latte.rasi;
  };

}
