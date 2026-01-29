{ pkgs, ... }:

# Papirus doesn't have nice alarm-clock icons and/or falling back to hicolor's. (Anyway, I don't like it)
# This wrapper adds custom alarm-clock icons to both Papirus-Dark and Papirus-Light themes.

base:
pkgs.runCommand "catppuccin-papirus-folders-custom-icons"
  {
    nativeBuildInputs = [ pkgs.imagemagick ];
  }
  ''
    # Copy the package
    cp -rL ${base} $out
    chmod -R u+w $out

    # Add our icons
    for theme in Papirus-Dark Papirus-Light; do
      mkdir -p $out/share/icons/$theme/scalable/apps
      
      if [ "$theme" = "Papirus-Dark" ]; then
        cp ${../../icons/alarm-clock-applet/alarm-clock-dark.svg} \
           $out/share/icons/$theme/scalable/apps/alarm-clock.svg
        cp ${../../icons/alarm-clock-applet/alarm-clock-triggered-dark.svg} \
           $out/share/icons/$theme/scalable/apps/alarm-clock-triggered.svg
        cp ${../../icons/alarm-clock-applet/alarm-timer-dark.svg} \
           $out/share/icons/$theme/scalable/apps/alarm-timer.svg
      else
        cp ${../../icons/alarm-clock-applet/alarm-clock-light.svg} \
           $out/share/icons/$theme/scalable/apps/alarm-clock.svg
        cp ${../../icons/alarm-clock-applet/alarm-clock-triggered-light.svg} \
           $out/share/icons/$theme/scalable/apps/alarm-clock-triggered.svg
        cp ${../../icons/alarm-clock-applet/alarm-timer-light.svg} \
           $out/share/icons/$theme/scalable/apps/alarm-timer.svg
      fi
      
      for size in 16 22 24 32 48 64; do
        mkdir -p $out/share/icons/$theme/''${size}x''${size}/apps
        for icon in alarm-clock alarm-clock-triggered alarm-timer; do
        ${pkgs.imagemagick}/bin/magick convert \
            -background none \
            -resize ''${size}x''${size} \
            $out/share/icons/$theme/scalable/apps/$icon.svg \
            $out/share/icons/$theme/''${size}x''${size}/apps/$icon.png
        done
      done
    done
  ''
