{ ... }: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch \"hl.dsp.dpms('on')\"";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch \"hl.dsp.dpms('off')\"";
          on-resume = "hyprctl dispatch \"hl.dsp.dpms('on')\"";
        }
      ];
    };
  };
}
