import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

Item {
  id: root

  property Item tooltipHost: null
  property Item panelHost: null
  property bool detailsOpen: false

  readonly property int unread: Notifications.unreadCount

  visible: !Notifications.dnd && Notifications.history.count > 0
  implicitWidth: 30
  implicitHeight: 30

  onVisibleChanged: if (!visible)
    detailsOpen = false

  BarButton {
    id: button

    anchors.fill: parent
    icon: "bell"
    checked: root.detailsOpen
    tooltip: "Notifications"
    tooltipHost: root.tooltipHost
    onClicked: {
      root.detailsOpen = !root.detailsOpen;
      if (root.detailsOpen) {
        Notifications.markRead();
        Notifications.clearPopups();
        panel.place();
      }
    }
  }

  Rectangle {
    visible: root.unread > 0
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.topMargin: -2
    anchors.rightMargin: -2
    implicitWidth: Math.max(14, badgeText.implicitWidth + 6)
    implicitHeight: 14
    radius: 7
    color: Theme.destructive

    Text {
      id: badgeText

      anchors.centerIn: parent
      text: root.unread > 9 ? "9+" : root.unread
      color: "#ffffff"
      font.family: Theme.fontFamily
      font.pixelSize: 10
      font.bold: true
    }
  }

  Rectangle {
    id: panel

    parent: root.panelHost ?? root
    visible: root.detailsOpen

    width: 380
    height: body.implicitHeight + 16
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: Theme.radius

    function place() {
      const host = root.panelHost;
      if (!host)
        return;

      const origin = root.mapToItem(host, 0, 0);
      const aligned = origin.x + root.width - panel.width;
      panel.x = Math.round(Math.max(4, Math.min(host.width - panel.width - 4, aligned)));
      panel.y = Theme.barHeight + 4;
    }

    MouseArea {
      anchors.fill: parent
    }

    ColumnLayout {
      id: body

      x: 8
      y: 8
      width: panel.width - 16
      spacing: 6

      RowLayout {
        Layout.fillWidth: true

        Text {
          Layout.fillWidth: true
          text: "Notifications"
          color: Theme.fg
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
          font.bold: true
        }

        BarButton {
          icon: "trash"
          tooltip: "Tout effacer"
          tooltipHost: root.tooltipHost
          implicitWidth: 24
          implicitHeight: 24
          onClicked: {
            Notifications.clearHistory();
            root.detailsOpen = false;
          }
        }
      }

      Repeater {
        model: Notifications.history

        delegate: Rectangle {
          id: entry

          required property string summary
          required property string body
          required property string appName
          required property string appIcon
          required property string image
          required property int index

          readonly property string iconSource: image.length > 0 ? image : (appIcon.length > 0 ? Quickshell.iconPath(appIcon, true) : "")

          Layout.fillWidth: true
          implicitHeight: entryContent.implicitHeight + 12
          radius: Theme.radius
          color: Theme.alpha(Theme.fg, 0.05)

          RowLayout {
            id: entryContent

            x: 8
            y: 6
            width: parent.width - 16
            spacing: 8

            Rectangle {
              Layout.alignment: Qt.AlignTop
              implicitWidth: 24
              implicitHeight: 24
              radius: Theme.radius
              color: Theme.alpha(Theme.fg, 0.08)

              Image {
                id: entryIconImg

                anchors.fill: parent
                anchors.margins: 4
                source: entry.iconSource
                fillMode: Image.PreserveAspectFit
                visible: status === Image.Ready
              }

              Icon {
                anchors.centerIn: parent
                visible: entryIconImg.status !== Image.Ready
                icon: "bell"
                size: 14
              }
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 2

              Text {
                Layout.fillWidth: true
                visible: entry.appName.length > 0
                text: entry.appName
                color: Theme.alpha(Theme.fg, 0.6)
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
              }

              Text {
                Layout.fillWidth: true
                text: entry.summary
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
                elide: Text.ElideRight
              }

              Text {
                Layout.fillWidth: true
                visible: entry.body.length > 0
                text: entry.body
                color: Theme.alpha(Theme.fg, 0.8)
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
              }
            }

            BarButton {
              icon: "x"
              implicitWidth: 22
              implicitHeight: 22
              tooltipHost: root.tooltipHost
              onClicked: Notifications.removeHistoryItem(entry.index)
            }
          }
        }
      }
    }
  }
}
