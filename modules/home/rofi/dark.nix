{ lib, ... }:
{
  home.file.".config/rofi/config.rasi".text = lib.mkForce ''
    @import "~/.config/rofi/configs/config-base.rasi"
    @theme "~/.config/rofi/themes/catppuccin-macchiato-complete.rasi"
  '';
  home.file.".config/rofi/config-long.rasi".text = lib.mkForce ''
    @import "~/.config/rofi/configs/config-long.rasi"
    @theme "~/.config/rofi/themes/catppuccin-macchiato-long.rasi"
  '';
}
