{ pkgs, lib }:

pkgs.writeShellScriptBin "monitor-post-apply" ''
  current_mon=$(hyprctl -j monitors 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name')
  current_ws=$(hyprctl -j activeworkspace 2>/dev/null | ${pkgs.jq}/bin/jq -r '.name')
  hyprctl -j workspacerules 2>/dev/null \
    | ${pkgs.jq}/bin/jq -r \
        --argjson ws "$(hyprctl -j workspaces 2>/dev/null)" \
        --argjson mons "$(hyprctl -j monitors 2>/dev/null)" '
        ($mons | map(.name)) as $names
        | .[] | select(.monitor != "" and (.monitor | IN($names[])))
        | . as $r | select($ws | any(.name == $r.workspaceString and .monitor != $r.monitor))
        | "\(.workspaceString) \(.monitor)"' \
    | while read -r ws monitor; do
        hyprctl dispatch "hl.dsp.workspace.move({ workspace = \"$ws\", monitor = \"$monitor\" })" 2>/dev/null || true
      done
  # a monitor showing a workspace no rule binds to it (e.g. one created on connect) gets its default one
  hyprctl -j workspacerules 2>/dev/null \
    | ${pkgs.jq}/bin/jq -r --argjson mons "$(hyprctl -j monitors 2>/dev/null)" '
        . as $rules | $mons[] | . as $m
        | select(any($rules[]; .monitor == $m.name and .workspaceString == $m.activeWorkspace.name) | not)
        | ($rules | map(select(.monitor == $m.name and .default == true)) | first) as $d
        | select($d != null)
        | "\($m.name) \($d.workspaceString)"' \
    | while read -r monitor ws; do
        hyprctl dispatch "hl.dsp.focus({ monitor = \"$monitor\" })" 2>/dev/null || true
        hyprctl dispatch "hl.dsp.focus({ workspace = \"$ws\" })" 2>/dev/null || true
      done
  # focusing a workspace that no longer exists would recreate it
  if hyprctl -j workspaces 2>/dev/null | ${pkgs.jq}/bin/jq -e --arg ws "$current_ws" 'any(.[]; .name == $ws)' >/dev/null; then
    hyprctl dispatch "hl.dsp.focus({ workspace = \"$current_ws\" })" 2>/dev/null || true
  elif [ -n "$current_mon" ]; then
    hyprctl dispatch "hl.dsp.focus({ monitor = \"$current_mon\" })" 2>/dev/null || true
  fi
  # # restart awww: monitor moves can strand its surfaces and it has no in-process recreate
  # pkill -x awww-daemon 2>/dev/null || true
  # setsid awww-daemon --format xrgb >/dev/null 2>&1 &
  # sleep 1
  # set-wallpaper 2>/dev/null || true
''
