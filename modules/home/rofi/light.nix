{ ... }:
{
  home.file.".config/rofi/config.rasi".text = ''
    @import "~/.config/rofi/configs/config-base.rasi"
    @theme "~/.config/rofi/themes/catppuccin-latte-complete.rasi"
  '';
  home.file.".config/rofi/config-long.rasi".text = ''
    @import "~/.config/rofi/configs/config-long.rasi"
    @theme "~/.config/rofi/themes/catppuccin-latte-long.rasi"
  '';
  home.file.".config/rofi/config-popup.rasi".text = ''
    @import "~/.config/rofi/configs/config-popup.rasi"
    @theme "~/.config/rofi/themes/catppuccin-latte-popup.rasi"
  '';
}
