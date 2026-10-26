{ pkgs, ... }:

pkgs.writeScriptBin "run-cleanup" ''
  #!${pkgs.zsh}/bin/zsh

  # Usage: run-cleanup '<cleanup command>' <command> [args...]
  # Runs <command>, then <cleanup command> when it ends or the terminal closes.
  cleanup_cmd=$1
  shift

  trap 'exit 129' HUP
  trap 'exit 143' TERM
  trap 'eval "$cleanup_cmd" </dev/null >/dev/null 2>&1' EXIT

  "$@"
  read
''
