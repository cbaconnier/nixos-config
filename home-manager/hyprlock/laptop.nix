{ ... }: {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
      };
      background = [{
        path = "screenshot";
        blur_passes = 3;
      }];
      "input-field" = [{
        size = "20%, 5%";
        outline_thickness = 3;
        inner_color = "rgba(0, 0, 0, 0.5)";
        outer_color = "rgba(255, 255, 255, 0.5)";
        font_color = "rgb(255, 255, 255)";
        fade_on_empty = true;
        rounding = 15;
        placeholder_text = "";
        fail_text = "$PAMFAIL";
        dots_text_format = "●";
        dots_size = 0.4;
        dots_spacing = 0.3;
        position = "0, -160";
        halign = "center";
        valign = "center";
      }];
      label = [{
        text = "$TIME";
        font_size = 96;
        color = "rgba(255, 255, 255, 0.9)";
        position = "0, 80";
        halign = "center";
        valign = "center";
      }];
    };
  };
}
