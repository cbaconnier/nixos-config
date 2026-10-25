-- Firefox-specific keybindings

-- When Firefox is focused, make CTRL+E send CTRL+ALT+Z, otherwise forward CTRL+E to the focused window.
hl.bind("CTRL + E", function()
	local win = hl.get_active_window()
	if win and win.class == "firefox" then
		hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL+ALT", key = "z" }))
	else
		hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "e" }))
	end
end)
