import QtQml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import ".."

RowLayout {
  id: root

  property bool enabled: true
  readonly property var active: [...server.trackedNotifications.values]
  readonly property var newest: active.length > 0 ? active[active.length - 1] : null

  visible: enabled && newest !== null
  spacing: 8
  Layout.alignment: Qt.AlignVCenter

  NotificationServer {
    id: server

    actionsSupported: true
    bodySupported: true
    imageSupported: true

    onNotification: notif => {
      if (root.enabled)
        notif.tracked = true;
    }
  }

  Instantiator {
    model: server.trackedNotifications

    delegate: Timer {
      required property var modelData

      interval: 5000
      running: true
      onTriggered: modelData.expire()
    }
  }

  Icon {
    Layout.alignment: Qt.AlignVCenter
    icon: "notification-symbolic"
  }

  Text {
    Layout.alignment: Qt.AlignVCenter
    Layout.maximumWidth: 400
    text: root.newest?.summary ?? ""
    elide: Text.ElideRight
    color: Theme.fg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.bold: true
  }
}
