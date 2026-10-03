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

  // Follow the focused monitor instead of sticking to one screen.
  screen: {
    for (const s of Quickshell.screens) {
      if (Hyprland.monitorFor(s) === Hyprland.focusedMonitor)
        return s;
    }
    return Quickshell.screens[0];
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
