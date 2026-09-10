---------------------
---- KEYBINDINGS ----
---------------------
-- See https://wiki.hypr.land/Configuring/Binds/ for more.
-- hl.BindOptions flags used below:
--   locked    -> still works while an input inhibitor (lockscreen) is active
--   repeating -> repeats while held
--   mouse     -> mouse drag bind

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("pkill rofi || rofi -show drun -modes drun"))
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("pkill rofi || rofi -show window -modes window"))

hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("power-menu"))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("open-project --rofi"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("kitty --directory ~/Documents/obsidian -e nvim"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("emoji-picker"))

-- pkill would kill itself (its args contain "clipse-app"), so just spawn it.
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("kitty --class clipse-app -e clipse"))

-- Glasscope: liquid-glass magnifier (see plugin.lua for its config)
-- bindr-on-modifier-release (mods=SUPER, key=Alt_L) doesn't reliably fire
-- once ALT was also part of the scroll binds above, so we track the raw
-- Alt key state instead. evdev KEY_LEFTALT=56 / KEY_RIGHTALT=100, xkbcommon
-- keycodes are +8, and state 0 is "released" (WL_KEYBOARD_KEY_STATE).
local ALT_KEYCODES = { [56 + 8] = true, [100 + 8] = true }
local KEYSTATE_RELEASED = 0
local glasscopeZoomHeld = false

local function glasscopeZoomShow(delta)
	glasscopeZoomHeld = true
	hl.plugin.glasscope.show()
	hl.plugin.glasscope.adjust_zoom(delta)
end

hl.bind(mainMod .. " + ALT + mouse_up", function()
	glasscopeZoomShow(0.2)
end, { description = "Glasscope show + zoom in" })
hl.bind(mainMod .. " + ALT + mouse_down", function()
	glasscopeZoomShow(-0.2)
end, { description = "Glasscope show + zoom out" })

hl.on("input.keyboard.key", function(keycode, _time, state)
	if not glasscopeZoomHeld or state ~= KEYSTATE_RELEASED or not ALT_KEYCODES[keycode] then
		return
	end

	glasscopeZoomHeld = false
	hl.plugin.glasscope.hide()
end)

-- Move focus
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Move window
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.layout("swapsplit"))

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.window.pin())

-- Kiosk mode: hides the bar and lets Firefox fake-fullscreen (chrome hidden) on this workspace.
local kioskDecoupleFirefoxFullscreen = hl.window_rule({
	name = "kiosk-decouple-firefox-fullscreen",
	match = { class = "^(firefox)$" },
	sync_fullscreen = false,
	enabled = false,
})

local kioskWorkspaces = {}

local function applyKioskBar(workspaceId)
	kioskDecoupleFirefoxFullscreen:set_enabled(kioskWorkspaces[workspaceId] == true)
end

-- Re-apply whenever the focused workspace changes, so returning to a
-- workspace always shows its own kiosk state, not whatever was last toggled.
hl.on("workspace.active", function(ws)
	applyKioskBar(ws.id)
end)

hl.bind(mainMod .. " + B", function()
	local ws = hl.get_active_workspace()
	if not ws then
		return
	end

	kioskWorkspaces[ws.id] = not kioskWorkspaces[ws.id]
	applyKioskBar(ws.id)

	hl.exec_cmd("qs ipc call bar setKiosk " .. ws.id .. " " .. tostring(kioskWorkspaces[ws.id]))
end)

-- Gaps/border/rounding
local gapsHidden = false

hl.bind(mainMod .. " + minus", function()
	gapsHidden = not gapsHidden

	if gapsHidden then
		hl.config({
			general = { gaps_in = 0, gaps_out = 0, border_size = 0 },
			decoration = { rounding = 0 },
		})
	else
		hl.config({
			general = { gaps_in = DEFAULT_GAPS_IN, gaps_out = DEFAULT_GAPS_OUT, border_size = DEFAULT_BORDER_SIZE },
			decoration = { rounding = DEFAULT_ROUNDING },
		})
	end
end)

-- Switch / move-to workspaces with mainMod (+ SHIFT) + [1-0]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspaces 11 and 12 (Swiss-FR keyboard symbols)
hl.bind(mainMod .. " + apostrophe", hl.dsp.focus({ workspace = 11 }))
hl.bind(mainMod .. " + dead_circumflex", hl.dsp.focus({ workspace = 12 }))
hl.bind(mainMod .. " + SHIFT + apostrophe", hl.dsp.window.move({ workspace = 11 }))
hl.bind(mainMod .. " + SHIFT + dead_circumflex", hl.dsp.window.move({ workspace = 12 }))

-- Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Screenshot
hl.bind(
	"Print",
	hl.dsp.exec_cmd(
		[[grim -g "$(slurp -o -r)" -t ppm - | satty --filename - --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png]]
	)
)

-- Screenshot current screen with 5 seconds delay + cursor
hl.bind(
	mainMod .. " + Print",
	hl.dsp.exec_cmd([[
      hyprctl notify -1 5000 0 "Screenshot in 5s..." ; sleep 5 && grim -c -o "$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')" -t ppm - | satty --filename - --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H-%M-%S').png
  ]])
)

-- Move / resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume controls
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

-- Microphone mute
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("F20", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true }) -- Keychron K8 Pro custom binding

-- Brightness controls
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Media controls
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

------------------------
---- Resize submap  ----
------------------------
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
	hl.bind("l", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
	hl.bind("h", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
	hl.bind("k", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
	hl.bind("j", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })

	-- Back to the global submap
	hl.bind("escape", hl.dsp.submap("reset"))
end)
