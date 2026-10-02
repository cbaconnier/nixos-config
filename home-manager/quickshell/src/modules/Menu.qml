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

  readonly property bool nightLightOn: nightLight.on

  function setNightLight(v: bool) {
    nightLight.apply(v);
  }

  property string activeList: ""
  property Item activeAnchor: null

  readonly property int panelWidth: 352

  visible: open
  implicitWidth: panel.width
  implicitHeight: panel.height

  onOpenChanged: {
    if (open) {
      awake.refresh();
      brightness.refresh();
      nightLight.refresh();
    } else
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

        Item {
          Layout.fillWidth: true
        }

        BarButton {
          icon: "view-app-grid-symbolic"
          tooltip: "Applications"
          tooltipHost: root.tooltipHost
          onClicked: rofiProc.startDetached()
        }

        BarButton {
          icon: "system-shutdown-symbolic"
          tooltip: "Alimentation"
          tooltipHost: root.tooltipHost
          onClicked: powerProc.startDetached()
        }
      }

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
        spacing: 4

        Brightness {
          id: brightness

          Layout.fillWidth: true
          showSlider: true
          tooltipHost: root.tooltipHost
        }

        Item {
          implicitWidth: 22
          implicitHeight: 1
        }
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        implicitHeight: 1
        color: Theme.border
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
          text: "Réglages rapides"
          color: Theme.alpha(Theme.fg, 0.6)
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize - 1
        }

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: quickToggles.implicitHeight + 16
          radius: Theme.radius
          color: Theme.alpha(Theme.fg, 0.05)

          RowLayout {
            id: quickToggles

            anchors.centerIn: parent
            spacing: 6

            BarButton {
              checked: !notifToggle.checked
              icon: notifToggle.checked ? "notification-symbolic" : "notification-disabled-symbolic"
              tooltip: notifToggle.checked ? "Désactiver les notifications" : "Activer les notifications"
              tooltipHost: root.tooltipHost
              onClicked: notifToggle.checked = !notifToggle.checked
            }

            KeepAwake {
              id: awake

              tooltipHost: root.tooltipHost
            }

            NightLight {
              id: nightLight

              tooltipHost: root.tooltipHost
            }
          }
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
