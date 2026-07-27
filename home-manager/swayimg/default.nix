{ ... }:

# https://github.com/artemsen/swayimg
# swayimg 5.x replaced the ini config with a Lua init file.
# This keeps swayimg's built-in default bindings and only layers our
# customisations (vim navigation, fixed zoom, custom modes, etc.) on top.

{
  programs.swayimg = {
    enable = true;
    initLua = ''
      local V = swayimg.viewer
      local G = swayimg.gallery
      local S = swayimg.slideshow

      -- old list.all = "yes": open every file from the same directory
      swayimg.imagelist.enable_adjacent(true)

      local function info_toggle()
        if swayimg.text.visible() then
          swayimg.text.hide()
        else
          swayimg.text.show()
        end
      end

      -- move image by a fraction of the window size
      local function move(mode, dx, dy)
        local wnd = swayimg.get_window_size()
        local pos = mode.get_position()
        mode.set_abs_position(
          math.floor(pos.x + wnd.width * dx),
          math.floor(pos.y + wnd.height * dy))
      end

      -- relative zoom around the window centre
      local function zoom(mode, factor)
        local scale = mode.get_scale()
        mode.set_abs_scale(scale + scale * factor)
      end

      local function remove_current(get_image)
        local img = get_image()
        os.remove(img.path)
        swayimg.text.set_status("Removed: " .. img.path)
      end

      -- ===== Viewer =====
      V.on_key("j", function() V.switch_image("next") end)
      V.on_key("k", function() V.switch_image("prev") end)
      V.on_key("Left", function() V.switch_image("prev") end)
      V.on_key("Right", function() V.switch_image("next") end)
      V.on_key("Home", function() V.switch_image("first") end)
      V.on_key("End", function() V.switch_image("last") end)
      V.on_key("space", function() V.switch_image("next") end)
      V.on_key("BackSpace", function() V.switch_image("prev") end)

      V.on_key("Shift-h", function() move(V, 0.1, 0) end)
      V.on_key("Shift-l", function() move(V, -0.1, 0) end)
      V.on_key("Shift-k", function() move(V, 0, 0.1) end)
      V.on_key("Shift-j", function() move(V, 0, -0.1) end)
      V.on_key("Shift-Left", function() move(V, 0.1, 0) end)
      V.on_key("Shift-Right", function() move(V, -0.1, 0) end)
      V.on_key("Shift-Up", function() move(V, 0, 0.1) end)
      V.on_key("Shift-Down", function() move(V, 0, -0.1) end)

      V.on_key("1", function() V.set_fix_scale("optimal") end)
      V.on_key("2", function() V.set_fix_scale("fit") end)
      V.on_key("3", function() V.set_fix_scale("fill") end)
      V.on_key("4", function() V.set_fix_scale("width") end)
      V.on_key("5", function() V.set_fix_scale("height") end)
      V.on_key("6", function() V.set_fix_scale("real") end)

      V.on_key("r", function() V.rotate(90) end)
      V.on_key("Shift-r", function() V.rotate(270) end)
      V.on_key("v", function() V.flip_vertical() end)
      V.on_key("Shift-v", function() V.flip_horizontal() end)

      V.on_key("g", function() swayimg.set_mode("gallery") end)
      V.on_key("Return", function() swayimg.set_mode("gallery") end)
      V.on_key("i", info_toggle)
      V.on_key("q", function() swayimg.exit() end)

      V.on_key("a", function() V.set_animation() end)
      V.on_key("period", function() V.next_frame() end)
      V.on_key("comma", function() V.prev_frame() end)

      V.on_key("Delete", function() remove_current(V.get_image) end)

      V.on_mouse("Ctrl-ScrollUp", function() V.switch_image("prev") end)
      V.on_mouse("Ctrl-ScrollDown", function() V.switch_image("next") end)
      V.on_mouse("ScrollUp", function() zoom(V, 0.1) end)
      V.on_mouse("ScrollDown", function() zoom(V, -0.1) end)

      -- ===== Gallery =====
      G.on_key("h", function() G.switch_image("left") end)
      G.on_key("j", function() G.switch_image("down") end)
      G.on_key("k", function() G.switch_image("up") end)
      G.on_key("l", function() G.switch_image("right") end)
      G.on_key("space", function() G.switch_image("pgdown") end)
      G.on_key("v", function() swayimg.set_mode("viewer") end)
      G.on_key("i", info_toggle)
      G.on_key("q", function() swayimg.exit() end)
      G.on_key("equal", function() G.set_thumb_size(G.get_thumb_size() + 20) end)
      G.on_key("Delete", function() remove_current(G.get_image) end)
      G.on_mouse("ScrollUp", function() G.set_thumb_size(G.get_thumb_size() + 20) end)
      G.on_mouse("ScrollDown", function() G.set_thumb_size(G.get_thumb_size() - 20) end)

      -- ===== Slideshow =====
      S.on_key("Left", function() S.switch_image("prev") end)
      S.on_key("Right", function() S.switch_image("next") end)
      S.on_key("Home", function() S.switch_image("first") end)
      S.on_key("End", function() S.switch_image("last") end)
      S.on_key("space", function() swayimg.set_mode("viewer") end) -- no pause API; drop to viewer
      S.on_key("g", function() swayimg.set_mode("gallery") end)
      S.on_key("v", function() swayimg.set_mode("viewer") end)
      S.on_key("i", info_toggle)
      S.on_key("q", function() swayimg.exit() end)
    '';
  };
}
