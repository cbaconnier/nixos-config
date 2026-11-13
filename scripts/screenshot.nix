{ pkgs }:
pkgs.writeShellApplication {
  name = "screenshot";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.findutils
    pkgs.grim
    pkgs.jq
    pkgs.satty
    pkgs.slurp
    pkgs.wl-clipboard
  ];
  text = ''
    dir="$HOME/Pictures/Screenshots"
    inbox=/tmp/claude-inbox

    if [[ "''${1:-}" == --put ]]; then
      file="$inbox/shot-$(date '+%Y%m%d-%H%M%S').png"
      cat > "$file"
      if [[ ! -s "$file" ]]; then
        rm -f "$file"
        exit 1
      fi
      printf '%s' "$file" | wl-copy
      exit 0
    fi

    delay=0
    claude=0
    for arg in "$@"; do
      case "$arg" in
        --delay) delay=1 ;;
        --claude) claude=1 ;;
        *)
          echo "usage: screenshot [--delay] [--claude]" >&2
          exit 2
          ;;
      esac
    done

    if [[ $claude -eq 1 ]]; then
      mkdir -m 700 "$inbox" 2>/dev/null || true
      find "$inbox" -maxdepth 1 -name 'shot-*.png' -mmin +1440 -delete
      satty_args=(--copy-command "$0 --put")
    elif [[ $delay -eq 1 ]]; then
      satty_args=(--output-filename "$dir/satty-$(date '+%Y%m%d-%H-%M-%S').png")
    else
      satty_args=(--output-filename "$dir/satty-$(date '+%Y%m%d-%H:%M:%S').png")
    fi

    if [[ $delay -eq 1 ]]; then
      hyprctl notify -1 5000 0 "Screenshot in 5s..." || true
      sleep 5
      grim -c -o "$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')" -t ppm - \
        | satty --disable-notifications --filename - "''${satty_args[@]}"
    else
      grim -g "$(slurp -o -r)" -t ppm - \
        | satty --disable-notifications --filename - "''${satty_args[@]}"
    fi
  '';
}
