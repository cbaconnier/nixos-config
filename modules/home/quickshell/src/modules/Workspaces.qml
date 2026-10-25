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
        anchors.centerIn: parent
        text: chip.modelData.id
        color: chip.focused ? Theme.selectedFg : Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
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
