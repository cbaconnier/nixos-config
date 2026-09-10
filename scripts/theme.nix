{ pkgs, ... }:

pkgs.writeShellScriptBin "theme" ''
  THEME_NAME="$1"
  if [ -z "$THEME_NAME" ]; then
    echo "Please provide a theme name as an argument."
    exit 1
  fi

  GEN=$(${pkgs.systemd}/bin/systemctl show "home-manager-$USER" -p ExecStart \
    | ${pkgs.gnugrep}/bin/grep -oP '/nix/store/[a-z0-9]+-home-manager-generation')

  if [ -z "$GEN" ]; then
    echo "Could not find home-manager generation."
    exit 1
  fi

  THEME_PATH="$GEN/specialisation/$THEME_NAME"

  if [ ! -f "$THEME_PATH/activate" ]; then
    echo "Theme '$THEME_NAME' not found."
    exit 1
  fi

  echo "Activating theme: $THEME_NAME"
  "$THEME_PATH/activate"

  [ -x "$HOME/.cache/theme-apply.sh" ] && "$HOME/.cache/theme-apply.sh"

  PALETTE="$HOME/.cache/quickshell-palette.qml"
  if [ -e "$PALETTE" ]; then
    for dest in "$HOME/.config/quickshell/default" "$HOME/nixos-config/home-manager/quickshell/src"; do
      [ -d "$dest" ] && install -m 0644 -T "$PALETTE" "$dest/Palette.qml"
    done
  fi

  qs -n > "$HOME/.cache/quickshell.log" 2>&1 &
  disown
''
