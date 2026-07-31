{
  pkgs,
  lib,
  config,
  ...
}:
let
  rofimojiKeywords = import ./rofimoji-keywords.nix { inherit pkgs; };
  rofimojiGroups = [
    "emojis_smileys_emotion"
    "emojis_people_body"
    "emojis_animals_nature"
    "emojis_food_drink"
    "emojis_activities"
    "emojis_travel_places"
    "emojis_objects"
    "emojis_symbols"
    "emojis_flags"
  ];
in
{
  programs.rofi = {
    enable = false;
    plugins = [ pkgs.rofi-calc ];
    extraConfig = { };
  };

  home.file = {
    ".config/rofi/config.rasi".text = ''
      @import "~/.config/rofi/configs/config-base.rasi"
    '';
    ".config/rofi/config-long.rasi".text = ''
      @import "~/.config/rofi/configs/config-long.rasi"
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
  }
  // lib.listToAttrs (
    map (
      group:
      lib.nameValuePair ".local/share/rofimoji/data/${group}.additional.csv" {
        source = "${rofimojiKeywords}/${group}.additional.csv";
      }
    ) rofimojiGroups
  );
}
