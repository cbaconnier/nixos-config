--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- See https://wiki.hypr.land/Configuring/Window-Rules/ for more.

-- Prevent windows from fullscreening themselves
-- hl.window_rule({
--   name = "suppress-maximize-events",
--   match = { class = ".*" },
--   suppress_event = "maximize",
-- })

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "pip",
	match = { title = "^(Picture-in-Picture)$" },
	pin = true,
	float = true,
	keep_aspect_ratio = true,
})

hl.window_rule({
	name = "steam-contacts",
	match = { title = "^(Liste de contacts)$" },
	float = true,
	size = "332 75%",
})

hl.window_rule({
	name = "gamescope",
	match = { class = "^(gamescope)$" },
	no_blur = true,
})

hl.window_rule({
	name = "power-menu",
	match = { title = "^(rofi - Power Menu|rofi - Shutdown delay:)$" },
	float = true,
	center = true,
	dim_around = true,
})

hl.window_rule({
	name = "thunar-rename",
	match = { class = "^(thunar)$", title = "Rename .*" },
	float = true,
	dim_around = true,
})

hl.window_rule({
	name = "discord",
	match = { class = "^(discord)$" },
	workspace = "10",
})

hl.window_rule({
	name = "kchat",
	match = { class = "^(kChat)$" },
	workspace = "10",
})

hl.window_rule({
	-- Prevents call window from following across workspaces
	name = "kchat-call-popup",
	match = { class = "^(kChat)$", title = "^(kChat)$" },
	float = true,
	keep_aspect_ratio = true,
	pin = true,
})
