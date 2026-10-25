-------------------------
---- NVIDIA ENV VARS ----
-------------------------
-- See https://wiki.hypr.land/nvidia/#environment-variables

hl.env("GBM_BACKEND", "nvidia-drm") -- remove if Firefox crashes
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia") -- remove if Discord/Zoom windows misbehave
hl.env("LIBVA_DRIVER_NAME", "nvidia") -- hardware video acceleration
