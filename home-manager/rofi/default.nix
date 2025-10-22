{ pkgs, lib, config, ... }: {
  programs.rofi = {
    enable = false;
    plugins = [ pkgs.rofi-calc ];
    extraConfig = { };
  };

  home.file = {
    # Dark theme as default - now this should work!
    ".config/rofi/config.rasi".text = ''
      @import "~/.config/rofi/configs/config-base.rasi"
      @theme "~/.config/rofi/themes/catppuccin-macchiato-complete.rasi"
    '';
    ".config/rofi/config-long.rasi".text = ''
      @import "~/.config/rofi/configs/config-long.rasi"
      @theme "~/.config/rofi/themes/catppuccin-macchiato-long.rasi"
    '';

    # Complete theme files (theme + layout combined)
    ".config/rofi/themes/catppuccin-macchiato-complete.rasi".text = ''
      ${builtins.readFile ./themes/catppuccin-macchiato.rasi}
      ${builtins.readFile ./layouts/layout-base.rasi}
    '';
    ".config/rofi/themes/catppuccin-macchiato-long.rasi".text = ''
      ${builtins.readFile ./themes/catppuccin-macchiato.rasi}
      ${builtins.readFile ./layouts/layout-long.rasi}
    '';
    ".config/rofi/themes/catppuccin-latte-complete.rasi".text = ''
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
