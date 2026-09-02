-------------------------
---- ENV VARIABLES ----
-------------------------
-- See https://wiki.hypr.land/configuring/core/environment-variables/
-- Must be set when withUWSM = false (hosts-config/hyprland.nix)

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

hl.env("CLUTTER_BACKEND", "wayland")
