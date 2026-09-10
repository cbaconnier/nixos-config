import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".."

Item {
  id: root

  property bool open: false
  property Item tooltipHost: null

  readonly property bool keepAwake: awake.awake

  function setKeepAwake(v: bool) {
    awake.apply(v);
  }
  property alias notificationsEnabled: notifToggle.checked

  property string activeList: ""
  property Item activeAnchor: null

  readonly property int panelWidth: 352

  visible: open
  implicitWidth: panel.width
  implicitHeight: panel.height

  onOpenChanged: {
    if (open)
      awake.refresh();
    else
      root.closeList();
  }

  function closeList() {
    root.activeList = "";
    root.activeAnchor = null;
  }

  function toggleList(kind: string, anchor: Item) {
    if (root.activeList === kind)
      root.closeList();
    else {
      root.activeList = kind;
      root.activeAnchor = anchor;
      list.refresh();
    }
  }

  Rectangle {
    id: panel

    width: root.panelWidth + 16
    height: content.implicitHeight + 16
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: Theme.radius

    MouseArea {
      anchors.fill: parent
    }

    ColumnLayout {
      id: content

      x: 8
      y: 8
      width: root.panelWidth
      spacing: 8

      RowLayout {
        Layout.fillWidth: true
        spacing: 4

        AudioControl {
          Layout.fillWidth: true
          node: Pipewire.defaultAudioSink
          showSlider: true
          tooltipHost: root.tooltipHost
        }

        BarButton {
          id: speakerExpander

          icon: root.activeList === "speakers" ? "pan-up-symbolic" : "pan-down-symbolic"
          tooltip: "Changer de haut-parleur"
          tooltipHost: root.tooltipHost
          checked: root.activeList === "speakers"
          implicitWidth: 22
          onClicked: root.toggleList("speakers", speakerExpander)
        }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: 4

        AudioControl {
          Layout.fillWidth: true
          node: Pipewire.defaultAudioSource
          showSlider: true
          isMicrophone: true
          tooltipHost: root.tooltipHost
        }

        BarButton {
          id: micExpander

          icon: root.activeList === "microphones" ? "pan-up-symbolic" : "pan-down-symbolic"
          tooltip: "Changer de microphone"
          tooltipHost: root.tooltipHost
          checked: root.activeList === "microphones"
          implicitWidth: 22
          onClicked: root.toggleList("microphones", micExpander)
        }
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        implicitHeight: 1
        color: Theme.border
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: 8

        BarButton {
          Layout.fillWidth: true
          filled: true
          checked: !notifToggle.checked
          icon: notifToggle.checked ? "notification-symbolic" : "notification-disabled-symbolic"
          tooltip: notifToggle.checked ? "Désactiver les notifications" : "Activer les notifications"
          tooltipHost: root.tooltipHost
          onClicked: notifToggle.checked = !notifToggle.checked
        }

        KeepAwake {
          id: awake

          Layout.fillWidth: true
          filled: true
          tooltipHost: root.tooltipHost
        }

        BarButton {
          Layout.fillWidth: true
          filled: true
          icon: "view-app-grid-symbolic"
          tooltip: "Applications"
          tooltipHost: root.tooltipHost
          onClicked: rofiProc.startDetached()
        }

        BarButton {
          Layout.fillWidth: true
          filled: true
          icon: "system-shutdown-symbolic"
          tooltip: "Alimentation"
          tooltipHost: root.tooltipHost
          onClicked: powerProc.startDetached()
        }
      }
    }
  }

  MouseArea {
    anchors.fill: panel
    enabled: root.activeList !== ""
    z: 5
    onClicked: root.closeList()
  }

  Rectangle {
    id: dropdown

    readonly property point anchorPos: root.activeAnchor ? root.activeAnchor.mapToItem(root, 0, 0) : Qt.point(0, 0)

    visible: root.activeList !== ""
    z: 10

    x: Math.round(Math.max(0, Math.min(panel.width - width, anchorPos.x + (root.activeAnchor?.width ?? 0) - width)))
    y: Math.round(anchorPos.y + (root.activeAnchor?.height ?? 0) + 4)

    width: 240
    height: list.implicitHeight + 12
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: Theme.radius

    MouseArea {
      anchors.fill: parent
    }

    AudioDevices {
      id: list

      x: 6
      y: 6
      width: parent.width - 12
      kind: root.activeList === "microphones" ? "microphones" : "speakers"
      onPicked: root.closeList()
    }
  }

  QtObject {
    id: notifToggle

    property bool checked: true
  }

  Process {
    id: rofiProc

    command: ["rofi", "-show", "drun", "-modes", "drun"]
  }

  Process {
    id: powerProc

    command: ["power-menu"]
  }
}
