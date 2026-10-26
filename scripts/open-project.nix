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

  add_tab() {
      printf 'new_tab %s\ncd %s\nlaunch %s\n\n' "$1" "$2" "$3"
  }

  add_suggested_tab() {
      printf 'new_tab %s\ncd %s\nlaunch zsh\n# launch %s %s\n\n' "$1" "$2" "--hold" "$3"
  }

  add_command_tab() {
      printf 'new_tab %s\ncd %s\nlaunch zsh\n# launch zsh -c '"'"'%s'"'"'\n\n' "$1" "$2" "$3"
  }

  rust_command() {
      local dir="$1"
      if grep -qs '^dev:' "$dir/Makefile"; then
          echo "make dev"
      else
          echo "cargo run"
      fi
  }

  has_compose_file() {
      local dir="$1" f
      for f in compose.yml compose.yaml docker-compose.yml docker-compose.yaml; do
          [[ -f "$dir/$f" ]] && return 0
      done
      return 1
  }

  node_dev_command() {
      local dir="$1" pm=npm
      [[ -f "$dir/pnpm-lock.yaml" ]] && pm=pnpm
      [[ -f "$dir/yarn.lock" ]] && pm=yarn
      [[ -f "$dir/bun.lockb" || -f "$dir/bun.lock" ]] && pm=bun
      echo "$pm run dev"
  }

  in_env() {
      local dir="$1" cmd="$2"
      if [[ -f "$dir/.envrc" ]] || grep -qs devShells "$dir/flake.nix" || [[ -f "$dir/shell.nix" ]]; then
          echo "direnv exec . $cmd"
      else
          echo "$cmd"
      fi
  }

  python_command() {
      local dir="$1"
      if [[ -f "$dir/main.py" ]]; then
          echo "python main.py"
      else
          echo "python"
      fi
  }

  create_session_file() {
      local selected="$1"
      local session_file="$2"
      local dir
      dir=$(printf '%q' "$selected")
      local sail=false
      grep -qs '"laravel/sail"' "$selected/composer.json" && sail=true

      {
          echo "# vim: ft=conf"
          echo ""
          add_tab nvim "$dir" "--hold nvim"
          add_tab git "$dir" "--hold lazygit"
          add_tab claude "$dir" "--hold claude --resume"
          add_tab shell "$dir" "zsh"
          if [[ ! -f "$selected/.envrc" ]]; then
              if grep -qs devShells "$selected/flake.nix"; then
                  echo "# To load the Nix environment: put \"use flake\" in .envrc, then run direnv allow"
                  echo ""
              elif [[ -f "$selected/shell.nix" ]]; then
                  echo "# To load the Nix environment: put \"use nix\" in .envrc, then run direnv allow"
                  echo ""
              fi
          fi
          if [[ "$sail" == "true" ]]; then
              add_suggested_tab dev "$dir" "zsh -c 'until ./vendor/bin/sail artisan --version >/dev/null 2>&1; do sleep 1; done; ./vendor/bin/sail artisan dev'"
              add_suggested_tab docker "$dir" "run-cleanup './vendor/bin/sail stop; rm -f public/hot' ./vendor/bin/sail up"
          else
              if grep -qs '"dev"' "$selected/package.json"; then
                  add_command_tab dev "$dir" "$(in_env "$selected" "$(node_dev_command "$selected")")"
              fi
              if has_compose_file "$selected"; then
                  add_suggested_tab docker "$dir" "run-cleanup 'docker compose stop' docker compose up"
              fi
          fi
          if [[ -f "$selected/Cargo.toml" ]]; then
              add_command_tab cargo "$dir" "$(in_env "$selected" "$(rust_command "$selected")")"
          fi
          if [[ -f "$selected/pyproject.toml" || -f "$selected/requirements.txt" ]]; then
              add_command_tab python "$dir" "$(in_env "$selected" "$(python_command "$selected")")"
          fi
          echo "#################### REMOVE ME -- START"
          echo "new_tab session-config"
          echo "cd $HOME/.config/kitty/sessions/"
          echo "launch nvim $(printf '%q' "$session_file")"
          echo "#################### REMOVE ME -- END"
      } > "$session_file"
  }

  session_file_for() {
      # Replace slashes and dots with underscores, remove home prefix
      local name
      name=$(echo "$1" | sed "s|$HOME/||" | sed 's|[/\.]|_|g')
      echo "$SESSIONS_DIR/''${name}.kitty-session"
  }

  open_project() {
      local selected="$1"
      
      # Exit if there's any selected project
      if [[ -z "$selected" ]]; then
          exit 0
      fi
      
      # Ensure sessions directory exists
      mkdir -p "$SESSIONS_DIR"
      
      session_file=$(session_file_for "$selected")
      
      # If session file doesn't exist, create it
      if [[ ! -f "$session_file" ]]; then
          create_session_file "$selected" "$session_file"
      fi
      
      ${pkgs.kitty}/bin/kitty --title "$(basename "$selected")" --session "$session_file" > /dev/null 2>&1 &
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
