{ pkgs, ... }:

pkgs.writeShellScriptBin "open-project" ''

  SESSIONS_DIR="$HOME/.config/kitty/sessions"

  run_rofi() {
    ${pkgs.rofi}/bin/rofi -theme ~/.config/rofi/config-long.rasi "$@"
  }

  run_fzf() {
      ${pkgs.fzf}/bin/fzf "$@"
  }

  get_projects() {
      find ~/Projects -maxdepth 2 -mindepth 1 -type d
      echo "$HOME/nixos-config"
      echo "$HOME/.config/nvim"
      echo "/tmp"
  }

  create_session_file() {
      local selected="$1"
      local session_file="$2"
      
      {
          echo "# vim: ft=conf"
          echo ""
          echo "new_tab nvim"
          echo "cd $(printf '%q' "$selected")"
          echo "launch --hold nvim"
          echo ""
          echo "new_tab git"
          echo "cd $(printf '%q' "$selected")"
          echo "launch --hold lazygit"
          echo ""
          echo "new_tab shell"
          echo "cd $(printf '%q' "$selected")"
          echo "launch zsh"
          echo ""
          echo "#################### REMOVE ME -- START"
          echo "new_tab session-config"
          echo "cd $HOME/.config/kitty/sessions/"
          echo "launch nvim $(printf '%q' "$session_file")"
          echo "#################### REMOVE ME -- END"
      } > "$session_file"
  }

  open_project() {
      local selected="$1"
      
      # Exit if there's any selected project
      if [[ -z "$selected" ]]; then
          exit 0
      fi
      
      # Ensure sessions directory exists
      mkdir -p "$SESSIONS_DIR"
      
      # Create unique session name using path structure
      # Replace slashes and dots with underscores, remove home prefix
      session_name=$(echo "$selected" | sed "s|$HOME/||" | sed 's|[/\.]|_|g')
      session_file="$SESSIONS_DIR/''${session_name}.kitty-session"
      
      # If session file doesn't exist, create it
      if [[ ! -f "$session_file" ]]; then
          create_session_file "$selected" "$session_file"
      fi
      
      ${pkgs.kitty}/bin/kitty --session "$session_file" > /dev/null 2>&1 &
  }

  # Check for --rofi flag
  USE_ROFI=false
  if [[ "$1" == "--rofi" ]]; then
      USE_ROFI=true
      shift  # Remove --rofi from arguments
  fi

  # Check for project path in argument 
  if [[ $# -eq 1 ]]; then
      open_project "$1"
      exit 0
  fi

  # Select a project
  projects=$(get_projects)

  if [[ "$USE_ROFI" == "true" ]]; then
      chosen=$(echo "$projects" | run_rofi -dmenu -i -p "Open Project" -selected-row 0)
  else
      chosen=$(echo "$projects" | run_fzf)
  fi

  # Handle selection
  open_project "$chosen"
''
