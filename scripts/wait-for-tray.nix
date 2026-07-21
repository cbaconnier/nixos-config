{ pkgs }:

# Waits until the StatusNotifier tray (ags) is up, 20s max.
pkgs.writeShellScriptBin "wait-for-tray" ''
  for _ in $(seq 100); do
    busctl --user get-property org.kde.StatusNotifierWatcher /StatusNotifierWatcher \
      org.kde.StatusNotifierWatcher IsStatusNotifierHostRegistered 2>/dev/null | grep -q true && exit 0
    sleep 0.2
  done
  exit 0
''
