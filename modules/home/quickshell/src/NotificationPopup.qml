import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "."
import "modules"

PanelWindow {
  id: root

  readonly property int cardWidth: 360

  // Follow the focused monitor, skipping screens being shared.
  screen: {
    const open = Quickshell.screens.filter(s => !Zen.isBroadcast(s.name));
    const candidates = open.length > 0 ? open : Quickshell.screens;
    for (const s of candidates) {
      if (Hyprland.monitorFor(s) === Hyprland.focusedMonitor)
        return s;
    }
    return candidates[0];
  }

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "quickshell-notifications"
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"

  anchors {
    top: true
    right: true
  }

  margins.top: Theme.barHeight + Theme.gap

  implicitWidth: cardWidth
  implicitHeight: screen.height - Theme.barHeight - Theme.gap

  mask: Region {
    item: list
  }

  ColumnLayout {
    id: list

    width: root.cardWidth
    spacing: 8

    Repeater {
      model: Notifications.popups

      delegate: NotificationCard {
        Layout.fillWidth: true
        squareRight: true
      }
    }
  }
}
