{ pkgs }:

pkgs.writeShellScriptBin "emoji-picker" ''
  ${pkgs.rofimoji}/bin/rofimoji \
    --no-frecency \
    --max-recent 0 \
    --selector rofi \
    --selector-args "-theme ~/.config/rofi/config.rasi" \
    --typer wtype \
    --clipboarder wl-copy
''
