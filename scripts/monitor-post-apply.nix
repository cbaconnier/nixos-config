{ pkgs, lib }:

pkgs.writeShellScriptBin "monitor-post-apply" ''
  current_ws=$(hyprctl -j activeworkspace 2>/dev/null | ${pkgs.jq}/bin/jq -r '.id')
  hyprctl -j workspacerules 2>/dev/null \
    | ${pkgs.jq}/bin/jq -r '.[] | select(.monitor != "") | "\(.workspaceString) \(.monitor)"' \
    | while read -r ws monitor; do
        hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"$monitor\" })" 2>/dev/null || true
        hyprctl dispatch "hl.dsp.focus({ monitor = \"$monitor\" })" 2>/dev/null || true
        hyprctl dispatch "hl.dsp.focus({ workspace = \"$ws\" })" 2>/dev/null || true
      done
  [ -n "$current_ws" ] && hyprctl dispatch "hl.dsp.focus({ workspace = \"$current_ws\" })" 2>/dev/null || true
  # restart awww: monitor moves can strand its surfaces and it has no in-process recreate
  pkill -x awww-daemon 2>/dev/null || true
  setsid awww-daemon --format xrgb >/dev/null 2>&1 &
  sleep 1
  set-wallpaper 2>/dev/null || true
  # in-process bar recreation keeps the tray watcher alive; full restart as
  # fallback ("ags request" exits 0 even without a handler, so check the reply)
  [ "$(ags request recreate-bars 2>/dev/null)" = "ok" ] || restart-ags 2>/dev/null || true
''
