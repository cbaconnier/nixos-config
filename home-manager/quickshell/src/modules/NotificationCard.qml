import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import ".."

Rectangle {
  id: root

  required property var notification

  // Square off the corners flush against the screen's right edge.
  property bool squareRight: false

  readonly property bool critical: notification.urgency === NotificationUrgency.Critical
  readonly property string iconSource: notification.image.length > 0 ? notification.image : (notification.appIcon.length > 0 ? Quickshell.iconPath(notification.appIcon, true) : "")

  implicitHeight: content.implicitHeight + 20
  radius: Theme.radius
  topRightRadius: squareRight ? 0 : Theme.radius
  bottomRightRadius: squareRight ? 0 : Theme.radius
  color: Theme.bg
  border.width: 1
  border.color: critical ? Theme.destructive : Theme.border

  opacity: 0
  Component.onCompleted: opacity = 1

  Behavior on opacity {
    NumberAnimation {
      duration: 150
    }
  }

  Timer {
    id: expireTimer

    // expireTimeout: 0 means "never", -1 means "use our default". Critical
    // notifications never auto-expire, per the freedesktop spec.
    interval: notification.expireTimeout > 0 ? notification.expireTimeout : 6000
    running: notification.expireTimeout !== 0 && !root.critical
    onTriggered: notification.expire()
  }

  HoverHandler {
    onHoveredChanged: {
      if (notification.expireTimeout === 0 || root.critical)
        return;
      if (hovered)
        expireTimer.stop();
      else
        expireTimer.restart();
    }
  }

  ColumnLayout {
    id: content

    x: 10
    y: 10
    width: parent.width - 20
    spacing: 6

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      Rectangle {
        implicitWidth: 28
        implicitHeight: 28
        radius: Theme.radius
        color: Theme.alpha(Theme.fg, 0.08)

        Image {
          id: appIconImg

          anchors.fill: parent
          anchors.margins: 5
          source: root.iconSource
          fillMode: Image.PreserveAspectFit
          visible: status === Image.Ready
        }

        Icon {
          anchors.centerIn: parent
          visible: appIconImg.status !== Image.Ready
          icon: "bell"
          size: 16
        }
      }

      Text {
        Layout.fillWidth: true
        text: notification.summary
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
        elide: Text.ElideRight
      }

      Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        radius: 10
        color: closeHover.containsMouse ? Theme.alpha(Theme.fg, 0.12) : "transparent"

        Icon {
          anchors.centerIn: parent
          icon: "close"
          size: 12
        }

        MouseArea {
          id: closeHover

          anchors.fill: parent
          hoverEnabled: true
          onClicked: {
            Notifications.markOneRead(root.notification);
            root.notification.dismiss();
          }
        }
      }
    }

    Text {
      Layout.fillWidth: true
      visible: notification.body.length > 0
      text: notification.body
      color: Theme.alpha(Theme.fg, 0.8)
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
      wrapMode: Text.WordWrap
      maximumLineCount: 3
      elide: Text.ElideRight
    }

    RowLayout {
      Layout.fillWidth: true
      visible: notification.actions.length > 0
      spacing: 6

      Item {
        Layout.fillWidth: true
      }

      Repeater {
        model: notification.actions

        delegate: Rectangle {
          id: actionPill

          required property var modelData

          implicitWidth: actionText.implicitWidth + 20
          implicitHeight: 30
          radius: Theme.radius
          color: actionHover.containsMouse ? Qt.lighter(Theme.selectedBg, 1.1) : Theme.selectedBg

          Text {
            id: actionText

            anchors.centerIn: parent
            // Some apps send the "default" action (triggered by clicking
            // the notification elsewhere) with no label text.
            text: actionPill.modelData.text && actionPill.modelData.text.trim().length > 0 ? actionPill.modelData.text : "Ouvrir"
            color: Theme.selectedFg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
          }

          MouseArea {
            id: actionHover

            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              Notifications.markOneRead(root.notification);
              actionPill.modelData.invoke();
              root.notification.dismiss();
            }
          }
        }
      }
    }
  }
}
