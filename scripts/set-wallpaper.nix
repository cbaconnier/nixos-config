{ pkgs, lib }:

let swwwExe = lib.getExe pkgs.swww;
in pkgs.writeShellScriptBin "set-wallpaper" ''
  #!${pkgs.bash}/bin/bash


  # set-wallpaper: A script to manage wallpapers using swww
  #
  # This script provides functionality to set and update wallpapers using the swww (Simple Wayland Wallpaper) utility.
  # It manages wallpapers in a dedicated directory and maintains a symlink to the current wallpaper.
  #
  # Usage:
  #   set-wallpaper                     : Updates the wallpaper using the current symlink
  #   set-wallpaper <path>              : Temporary set a new wallpaper until the theme is changed
  #   set-wallpaper <path> <theme>      : Sets a new wallpaper and set is has default for the theme
  #
  # The script performs the following actions:
  # 1. With no arguments: Updates the wallpaper using the current symlink
  # 2. With one argument (path): 
  #    - Creates a symlink to the new wallpaper
  #    - Updates the wallpaper
  # 3. With two arguments (path and theme):
  #    - Removes any existing wallpaper with the same theme
  #    - Copies the new wallpaper to the wallpapers directory with the theme prefix
  #    - Creates a symlink to the new wallpaper
  #    - Updates the wallpaper
  #
  # The script uses a directory structure as follows:
  # $HOME/.config/wallpapers/                  : Directory for storing theme wallpapers
  # $HOME/.config/wallpapers/current_wallpaper : Symlink to the current wallpaper
  #
  # Note: This script requires swww to be installed and available in the PATH.


  set -euo pipefail

  WALLPAPERS_DIR="$HOME/.config/wallpapers"
  CURRENT_WALLPAPER_FILE="$WALLPAPERS_DIR/current_wallpaper"

  update_wallpaper() {
    if [ -L "$CURRENT_WALLPAPER_FILE" ]; then
      ${swwwExe} img "$CURRENT_WALLPAPER_FILE"
    else
      echo "No wallpaper symlink found at $CURRENT_WALLPAPER_FILE" >&2
      exit 1
    fi
  }

  if [ $# -eq 0 ]; then
    update_wallpaper
  elif [ $# -eq 2 ]; then
    WALLPAPER_PATH=$(${pkgs.coreutils}/bin/readlink -f "$1")
    THEME="$2"
    
    if [ ! -f "$WALLPAPER_PATH" ]; then
      echo "File not found: $WALLPAPER_PATH" >&2
      exit 1
    fi

    ${pkgs.coreutils}/bin/mkdir -p "$WALLPAPERS_DIR"
    # Remove old themed wallpaper
    ${pkgs.coreutils}/bin/rm -f "$WALLPAPERS_DIR/$THEME"*
    # Copy new wallpaper with theme prefix
    EXTENSION=''${WALLPAPER_PATH##*.}
    ${pkgs.coreutils}/bin/cp "$WALLPAPER_PATH" "$WALLPAPERS_DIR/$THEME.$EXTENSION"
    # Update current_wallpaper symlink
    ${pkgs.coreutils}/bin/ln -sf "$WALLPAPERS_DIR/$THEME.$EXTENSION" "$CURRENT_WALLPAPER_FILE"
    update_wallpaper
  elif [ $# -eq 1 ]; then
    WALLPAPER_PATH=$(${pkgs.coreutils}/bin/readlink -f "$1")
    
    if [ ! -f "$WALLPAPER_PATH" ]; then
      echo "File not found: $WALLPAPER_PATH" >&2
      exit 1
    fi

    ${pkgs.coreutils}/bin/mkdir -p "$WALLPAPERS_DIR"
    # Update current_wallpaper symlink
    ${pkgs.coreutils}/bin/ln -sf "$WALLPAPER_PATH" "$CURRENT_WALLPAPER_FILE"
    update_wallpaper
  else
    echo "Usage: set-wallpaper [<path> [theme]]" >&2
    exit 1
  fi
''
