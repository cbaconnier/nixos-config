{ pkgs, ... }:

pkgs.writeShellScriptBin "p" ''
# Credit to ThePrimeagen

  if [[ $# -eq 1 ]]; then
    selected="$1"
  else
    items="$(find ~/Projects -maxdepth 2 -mindepth 1 -type d 2>/dev/null || true)"

    items=`find "$HOME/Projects" -maxdepth 2 -mindepth 1 -type d`
    items+=`echo -e "\n$HOME/nixos-config"`
    items+=`echo -e "\n$HOME/.config/nvim"`
    items+=`echo -e "\n/tmp"`
    selected=`echo "$items" | fzf`
  fi

  dirname=`basename $selected | sed 's/\./_/g'`

  # Try to switch to existing session
  if ${pkgs.tmux}/bin/tmux switch-client -t "=$dirname" 2>/dev/null; then
    exit 0
  fi

  # Create new session if it doesn't exist
  ${pkgs.tmux}/bin/tmux new-session -c "$selected" -d -s "$dirname" && \
    ${pkgs.tmux}/bin/tmux switch-client -t "$dirname" || \
    ${pkgs.tmux}/bin/tmux new -c "$selected" -A -s "$dirname"
''
