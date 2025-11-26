{ pkgs, ... }:

# https://github.com/artemsen/swayimg

{
  programs.swayimg = {
    enable = true;
    settings = {
      list.all = "yes";

      "keys.viewer" = {
        # Navigation
        "j" = "next_file";
        "k" = "prev_file";
        "Right" = "next_file";
        "Left" = "prev_file";
        "Home" = "first_file";
        "End" = "last_file";

        # Pan/move viewport 
        "Shift+h" = "step_left 10";
        "Shift+j" = "step_down 10";
        "Shift+k" = "step_up 10";
        "Shift+l" = "step_right 10";
        "Shift+Left" = "step_left 10";
        "Shift+Right" = "step_right 10";
        "Shift+Up" = "step_up 10";
        "Shift+Down" = "step_down 10";

        # Zoom
        "Shift+Plus" = "zoom +10";
        "Minus" = "zoom -10";
        "1" = "zoom optimal";
        "2" = "zoom fit";
        "3" = "zoom fill";
        "4" = "zoom width";
        "5" = "zoom height";
        "6" = "zoom real";

        # Rotation & flip
        "r" = "rotate_right";
        "Shift+r" = "rotate_left";
        "v" = "flip_vertical";
        "Shift+v" = "flip_horizontal";

        # Modes
        "g" = "mode gallery";
        "s" = "mode slideshow";
        "f" = "fullscreen";
        "Return" = "mode gallery";

        # Other
        "i" = "info";
        "Space" = "next_file";
        "BackSpace" = "prev_file";
        "Delete" = "exec rm -f '%' && echo 'File removed: %'; skip_file";

        # Animation
        "a" = "animation"; # Toggle animation
        "period" = "next_frame";
        "comma" = "prev_frame";

        # Exit
        "q" = "exit";
        "Escape" = "exit";

        # Mouse
        "Ctrl+ScrollUp" = "prev_file";
        "Ctrl+ScrollDown" = "next_file";
        "ScrollUp" = "zoom +10";
        "ScrollDown" = "zoom -10";
        "MouseLeft" = "drag";
      };

      "keys.gallery" = {
        # Arrow navigation in gallery grid
        "Left" = "step_left";
        "Right" = "step_right";
        "Up" = "step_up";
        "Down" = "step_down";
        "h" = "step_left";
        "j" = "step_down";
        "k" = "step_up";
        "l" = "step_right";

        # Page navigation
        "Prior" = "page_up";
        "Next" = "page_down";
        "Space" = "page_down";

        # Mode switching
        "Return" = "mode viewer";
        "v" = "mode viewer";
        "s" = "mode slideshow";
        "Escape" = "mode viewer";

        # Thumbnail size
        "Plus" = "thumb +20";
        "Equal" = "thumb +20";
        "Minus" = "thumb -20";

        # Other
        "f" = "fullscreen";
        "i" = "info";
        "Delete" = "exec rm -f '%' && echo 'File removed: %'; skip_file";
        "q" = "exit";

        # Mouse
        "MouseLeft" = "mode viewer";
        "ScrollUp" = "thumb +20";
        "ScrollDown" = "thumb -20";
      };

      "keys.slideshow" = {
        "Space" = "pause"; # Space to pause/play
        "Right" = "next_file";
        "Left" = "prev_file";
        "Home" = "first_file";
        "End" = "last_file";
        "g" = "mode gallery";
        "v" = "mode viewer";
        "f" = "fullscreen";
        "i" = "info";
        "q" = "exit";
        "Escape" = "exit";
      };
    };
  };

}
