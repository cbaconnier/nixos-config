-----------------------
---- LOOK AND FEEL ----
-----------------------
-- Refer to https://wiki.hypr.land/Configuring/Variables/

-- https://wiki.hypr.land/Configuring/Variables/#general
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 20,

    border_size = 2,

    -- https://wiki.hypr.land/Configuring/Variables/#variable-types for color info
    col = {
      active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },

    resize_on_border = true,

    -- See https://wiki.hypr.land/Configuring/Tearing/ before turning this on
    allow_tearing = false,

    snap = {
      enabled = true,
      window_gap = 10,  -- pixels
      monitor_gap = 10, -- pixels
    },
  },

  -- https://wiki.hypr.land/Configuring/Variables/#decoration
  decoration = {
    rounding = 10,

    -- Transparency of focused and unfocused windows
    active_opacity = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled = false,
      -- range = 4,
      -- render_power = 3,
      -- color = "rgba(1a1a1aee)",
    },

    -- https://wiki.hypr.land/Configuring/Variables/#blur
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },

  -- https://wiki.hypr.land/Configuring/Variables/#animations
  animations = {
    enabled = true,
  },

  -- See https://wiki.hypr.land/Configuring/Dwindle-Layout/ for more
  dwindle = {
    preserve_split = true,
    force_split = 2,
    precise_mouse_move = true,
  },

  -- See https://wiki.hypr.land/Configuring/Master-Layout/ for more
  master = {
    new_status = "master",
  },

  xwayland = {
    force_zero_scaling = true,
  },

  -- https://wiki.hypr.land/Configuring/Variables/#misc
  misc = {
    force_default_wallpaper = 0,  -- 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = true, -- disables the random hyprland logo background
    middle_click_paste = false,
    animate_manual_resizes = true,
  },

  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  },
})

-- Default animations, see https://wiki.hypr.land/Configuring/Animations/
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })
