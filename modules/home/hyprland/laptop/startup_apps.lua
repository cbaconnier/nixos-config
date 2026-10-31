-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
--

hl.on("hyprland.start", function()
	-- Needed for xdg-desktop-portal (file pickers, etc.) to work
	hl.exec_cmd("systemctl --user start nixos-fake-graphical-session.target")

	-- Restore the last home-manager specialisation theme, or default to dark.
	-- quickshell is started when we load the theme
	hl.exec_cmd([[{ cat ~/.cache/.current_theme 2>/dev/null || echo 'dark'; } | xargs theme]])

	hl.exec_cmd("awww-daemon --format xrgb")

	hl.exec_cmd("clipse -listen")
	hl.exec_cmd("systemctl --user start easyeffects")

	hl.exec_cmd("nm-applet &")
	hl.exec_cmd("filen-desktop &")
	hl.exec_cmd("discord", { workspace = "10 silent" })
end)

-- restart quickshell when the last output vanishes (laptop with lid close for instance)
hl.on("monitor.added", function()
	hl.exec_cmd(
		[[flock -n "$XDG_RUNTIME_DIR/qs-watch.lock" sh -c 'sleep 3; qs ipc --any-display show >/dev/null 2>&1 || restart-qs']]
	)
end)
