-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
--
-- hl.on("hyprland.start", ...) fires once when the compositor starts and does
-- NOT re-run on config reload.

hl.on("hyprland.start", function()
	-- Restore the last home-manager specialisation theme, or default to dark.
	hl.exec_cmd([[{ cat ~/.cache/.current_theme 2>/dev/null || echo 'dark'; } | xargs theme]])

	-- ags is started (and restarted on theme switch) by the theme script above
	hl.exec_cmd("awww-daemon --format xrgb")

	hl.exec_cmd("clipse -listen")
	hl.exec_cmd("systemctl --user start easyeffects")

	hl.exec_cmd("wait-for-tray && filen-desktop &")
	hl.exec_cmd("wait-for-tray && discord", { workspace = "10" })
end)
