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

	hl.exec_cmd("ags run &")
	hl.exec_cmd("awww-daemon --format xrgb")

	hl.exec_cmd("nm-applet &")
	hl.exec_cmd("clipse -listen")
	hl.exec_cmd("easyeffects --gapplication-service &")

	hl.exec_cmd("sleep 4 && filen-desktop &")
	hl.exec_cmd("sleep 4 && discord", { workspace = "10 silent" })
end)
