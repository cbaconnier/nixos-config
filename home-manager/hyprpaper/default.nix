{config, ...}:

{
  services.hyprpaper = {
    enable = true;
    settings = {
     ipc = "on";
     splash = false;
     splash_offset = 2.0;
     preload = [
        "${config.xdg.cacheHome}/wallpaper/dark.png"
        "${config.xdg.cacheHome}/wallpaper/light.png"
       ];
    };
  };

  specialisation.dark.configuration = {
      services.hyprpaper.settings.wallpaper = [
        ",${config.xdg.cacheHome}/wallpaper/dark.png"
      ];
   };

  specialisation.light.configuration = {
      services.hyprpaper.settings.wallpaper = [
        ",${config.xdg.cacheHome}/wallpaper/light.png"
      ];
   };

}
