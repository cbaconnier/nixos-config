import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "."
import "modules"

PanelWindow {
  id: root

  readonly property int cardWidth: 400

  screen: {
    const open = Quickshell.screens.filter(s => !Zen.isBroadcast(s.name));
    const candidates = open.length > 0 ? open : Quickshell.screens;
    for (const s of candidates) {
      if (Hyprland.monitorFor(s) === Hyprland.focusedMonitor)
        return s;
    }
    return candidates[0];
  }

  visible: Reminders.alerts.count > 0

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "quickshell-reminders"
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"

  anchors.top: true

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
      model: Reminders.alerts

      delegate: Rectangle {
        id: card

        required property int index
        required property string title
        required property string body
        required property bool muted

        Layout.fillWidth: true
        implicitHeight: content.implicitHeight + 20
        radius: Theme.radius
        color: Theme.bg
        border.width: 1
        border.color: Theme.border

        ColumnLayout {
          id: content

          x: 10
          y: 10
          width: parent.width - 20
          spacing: 8

          RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
              implicitWidth: 32
              implicitHeight: 32
              radius: 16
              color: Theme.selectedBg

              Icon {
                anchors.centerIn: parent
                icon: card.muted ? "bell-off" : "bell"
                size: 18
                color: Theme.selectedFg
              }

              MouseArea {
                anchors.fill: parent
                enabled: !card.muted
                cursorShape: Qt.PointingHandCursor
                onClicked: Reminders.mute(card.index)
              }
            }

            Text {
              Layout.fillWidth: true
              text: card.title
              color: Theme.fg
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize * 1.15
              font.bold: true
              wrapMode: Text.WordWrap
            }
          }

          Text {
            Layout.fillWidth: true
            visible: card.body.length > 0
            text: card.body
            color: Theme.alpha(Theme.fg, 0.8)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            wrapMode: Text.WordWrap
          }

          Rectangle {
            Layout.alignment: Qt.AlignRight
            implicitWidth: okText.implicitWidth + 28
            implicitHeight: 30
            radius: Theme.radius
            color: okHover.containsMouse ? Qt.lighter(Theme.selectedBg, 1.1) : Theme.selectedBg

            Text {
              id: okText

              anchors.centerIn: parent
              text: "OK"
              color: Theme.selectedFg
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize
              font.bold: true
            }

            MouseArea {
              id: okHover

              anchors.fill: parent
              hoverEnabled: true
              onClicked: Reminders.dismiss(card.index)
            }
          }
        }
      }
    }
  }
}
