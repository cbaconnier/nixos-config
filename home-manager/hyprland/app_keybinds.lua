-- Firefox-specific keybindings

-- When Firefox is focused, make CTRL+E send CTRL+ALT+Z, otherwise fall back to CTRL+E.
hl.bind("CTRL + E", hl.dsp.exec_cmd(
  [[bash -c "hyprctl activewindow -j | grep -q '\"class\": \"firefox\"' && wtype -M ctrl -M alt z -m alt -m ctrl || wtype -M ctrl e -m ctrl"]]
))
