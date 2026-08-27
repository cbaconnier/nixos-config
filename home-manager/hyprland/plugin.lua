-----------------
---- PLUGINS ----
-----------------

-- Glasscope: liquid-glass magnifier that follows the pointer.
-- See https://github.com/Horizon0427/Glasscope
if hl.plugin.glasscope ~= nil then
	hl.config({
		plugin = {
			glasscope = {
				enabled = true,
				radius = 190,
			},
		},
		binds = {
			scroll_event_delay = 0,
		},
	})
end
