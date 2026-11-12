{ pkgs, ... }:

pkgs.writeScriptBin "run-cleanup" ''
  #!${pkgs.zsh}/bin/zsh

  # Usage: run-cleanup '<cleanup command>' <command> [args...]
  # Runs <command>, then <cleanup command> when it ends or the terminal closes.
  cleanup_cmd=$1
  shift

  # zsh defers traps while a foreground command runs, so wait on a background one
  trap 'kill -HUP $child 2>/dev/null; wait $child; exit 129' HUP
  trap 'kill -TERM $child 2>/dev/null; wait $child; exit 143' TERM
  trap 'log=$(mktemp); eval "$cleanup_cmd" </dev/null >$log 2>&1; st=$?
    { print -r -- "cleanup: $cleanup_cmd (status $st)"; cat $log; } | ${pkgs.systemd}/bin/systemd-cat -t run-cleanup
    rm -f $log' EXIT

  "$@" <&0 &
  child=$!
  wait $child
  read
''
