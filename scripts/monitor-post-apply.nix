{ pkgs, lib }:

pkgs.writeShellScriptBin "monitor-post-apply" ''
  current_ws=$(hyprctl -j activeworkspace 2>/dev/null | ${pkgs.jq}/bin/jq -r '.id')
  hyprctl -j workspacerules 2>/dev/null \
    | ${pkgs.jq}/bin/jq -r '.[] | select(.monitor != "") | "\(.workspaceString) \(.monitor)"' \
    | while read -r ws monitor; do
        hyprctl dispatch moveworkspacetomonitor "$ws" "$monitor" 2>/dev/null || true
        hyprctl dispatch focusmonitor "$monitor" 2>/dev/null || true
        hyprctl dispatch workspace "$ws" 2>/dev/null || true
      done
  [ -n "$current_ws" ] && hyprctl dispatch workspace "$current_ws" 2>/dev/null || true
  set-wallpaper 2>/dev/null || true
  restart-ags 2>/dev/null || true
''
