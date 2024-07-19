{ pkgs, lib, home-manager, ... }:

pkgs.writeShellScriptBin "theme" ''
  THEME_NAME="$1"
  if [ -z "$THEME_NAME" ]; then
    echo "Please provide a theme name as an argument."
    exit 1
  fi

  GENERATIONS=$(${lib.getExe home-manager} generations | ${pkgs.gawk}/bin/awk -v FS='( : id | -> )' -v OFS="\t" '{print $3}')

  MAIN_GENERATION=""
  while IFS= read -r generation; do
    if [ -d "$generation/specialisation" ]; then
      MAIN_GENERATION="$generation"
      break
    fi
  done <<< "$GENERATIONS"

  if [ -z "$MAIN_GENERATION" ]; then
    echo "No specialisations found."
    exit 1
  fi

  THEME_PATH="$MAIN_GENERATION/specialisation/$THEME_NAME"

  if [ ! -f "$THEME_PATH/activate" ]; then
    echo "Theme '$THEME_NAME' not found."
    exit 1
  fi

  echo "Activating theme: $THEME_NAME"
  "$THEME_PATH/activate"
''
