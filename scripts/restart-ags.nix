{ pkgs, ... }:

pkgs.writeShellScriptBin "restart-ags" ''
  ags quit 2>/dev/null
  sleep 0.5
  ags run
''
