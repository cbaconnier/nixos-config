---------------
---- INPUT ----
---------------
-- https://wiki.hypr.land/Configuring/Variables/#input
hl.config({
  input = {
    kb_layout = "ch",
    kb_variant = "fr",
    kb_model = "",
    kb_options = "",
    kb_rules = "",

    repeat_rate = 50,
    repeat_delay = 300,

    follow_mouse = 2,
    mouse_refocus = false,

    sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

    touchpad = {
      natural_scroll = false,
    },
  },
})

-- https://wiki.hypr.land/Configuring/Variables/#gestures
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
-- hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })
