pragma Singleton

import QtQuick
import Quickshell

Singleton {
  // Hides the bar clutter
  property bool active: false
  property bool hideClock: false
  property var broadcastScreens: []

  function isBroadcast(name: string): bool {
    return broadcastScreens.includes(name);
  }

  function toggleBroadcast(name: string) {
    broadcastScreens = isBroadcast(name) ? broadcastScreens.filter(n => n !== name) : [...broadcastScreens, name];
  }

  onActiveChanged: if (!active)
    hideClock = false
}
