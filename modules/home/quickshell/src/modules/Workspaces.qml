import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import ".."

RowLayout {
  id: root

  required property HyprlandMonitor monitor

  spacing: Theme.itemSpacing

  Repeater {
    model: ScriptModel {
      values: [...Hyprland.workspaces.values].filter(ws => ws.monitor === root.monitor).sort((a, b) => a.id - b.id)
    }

    delegate: Rectangle {
      id: chip

      required property HyprlandWorkspace modelData
      readonly property bool focused: modelData.id === Hyprland.focusedWorkspace?.id

      implicitWidth: 28
      implicitHeight: 28
      radius: Theme.radius
      color: focused ? Theme.selectedBg : (mouse.hovered ? Theme.alpha(Theme.selectedBg, 0.15) : "transparent")

      Text {
        id: label
        anchors.centerIn: parent
        text: chip.modelData.id
        color: chip.focused ? Theme.selectedFg : Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
      }

      TextMetrics {
        id: metrics
        text: label.text
        font: label.font
      }

      Rectangle {
        visible: chip.modelData.active && !chip.focused
        x: Math.floor(label.x + metrics.tightBoundingRect.x + metrics.tightBoundingRect.width / 2 - width / 2)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        width: 4
        height: 4
        radius: 2
        color: Theme.selectedBg
      }

      HoverHandler {
        id: mouse
      }

      TapHandler {
        onTapped: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${chip.modelData.id} })`)
      }
    }
  }
}
