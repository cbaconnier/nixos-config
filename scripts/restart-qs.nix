{ pkgs, ... }:

pkgs.writeShellScriptBin "restart-qs" ''
  qs kill 2>/dev/null
  sleep 0.5
  qs > "$HOME/.cache/quickshell.log" 2>&1 &
  disown
''
