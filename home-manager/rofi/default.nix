{ pkgs, lib, config, ... }: {
  programs.rofi = {
    enable = true;
    plugins = [ pkgs.rofi-calc ];
  };

  # Light specialization configuration
  specialisation.light.configuration = {
    home.file = {
      ".config/rofi/config.rasi".text = ''
        @import "~/.config/rofi/configs/config-base.rasi"
        @theme "~/.config/rofi/themes/catppuccin-latte-base.rasi"
      '';
      ".config/rofi/config-long.rasi".text = ''
        @import "~/.config/rofi/configs/config-long.rasi"
        @theme "~/.config/rofi/themes/catppuccin-latte-long.rasi"
      '';
    };
  };

  # Dark specialization configuration
  specialisation.dark.configuration = {
    home.file = {
      ".config/rofi/config.rasi".text = ''
        @import "~/.config/rofi/configs/config-base.rasi"
        @theme "~/.config/rofi/themes/catppuccin-macchiato-base.rasi"
      '';
      ".config/rofi/config-long.rasi".text = ''
        @import "~/.config/rofi/configs/config-long.rasi"
        @theme "~/.config/rofi/themes/catppuccin-macchiato-long.rasi"
      '';
    };
  };

  # Merge and copy theme and layout files
  home.file = {
    ".config/rofi/themes/catppuccin-macchiato-base.rasi".text = ''
      ${builtins.readFile ./themes/catppuccin-macchiato.rasi}
      ${builtins.readFile ./layouts/layout-base.rasi}
    '';
    ".config/rofi/themes/catppuccin-macchiato-long.rasi".text = ''
      ${builtins.readFile ./themes/catppuccin-macchiato.rasi}
      ${builtins.readFile ./layouts/layout-long.rasi}
    '';
    ".config/rofi/themes/catppuccin-latte-base.rasi".text = ''
      ${builtins.readFile ./themes/catppuccin-latte.rasi}
      ${builtins.readFile ./layouts/layout-base.rasi}
    '';
    ".config/rofi/themes/catppuccin-latte-long.rasi".text = ''
      ${builtins.readFile ./themes/catppuccin-latte.rasi}
      ${builtins.readFile ./layouts/layout-long.rasi}
    '';

    # Original files for reference
    ".config/rofi/configs/config-base.rasi".source = ./configs/config-base.rasi;
    ".config/rofi/configs/config-long.rasi".source = ./configs/config-long.rasi;
  };
}
