import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import "."
import "modules"

Scope {
  id: bar

  required property ShellScreen screen
  property var kioskWorkspaces: new Set()

  readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
  readonly property int activeWorkspaceId: monitor?.activeWorkspace?.id ?? -1
  readonly property bool inKiosk: kioskWorkspaces.has(activeWorkspaceId)

  property bool hovering: false
  readonly property bool revealed: !inKiosk || hovering

  Timer {
    id: hideTimer
    interval: Theme.hideDelayMs
    onTriggered: bar.hovering = false
  }

  function onEnter() {
    hideTimer.stop();
    bar.hovering = true;
  }

  function onLeave() {
    hideTimer.restart();
  }

  PanelWindow {
    id: win

    screen: bar.screen
    visible: bar.revealed
    color: "transparent"

    readonly property bool panelOpen: menu.open || battery.detailsOpen || clock.calendarOpen

    implicitHeight: bar.screen.height

    anchors {
      top: true
      left: true
      right: true
    }

    exclusionMode: ExclusionMode.Normal
    exclusiveZone: bar.inKiosk ? 0 : Theme.barHeight

    mask: Region {
      item: maskItem
    }

    Item {
      id: maskItem

      width: win.width
      height: win.panelOpen ? win.height : Theme.barHeight
    }

    MouseArea {
      anchors.fill: parent
      enabled: win.panelOpen
      z: 0
      onClicked: {
        menu.open = false;
        battery.detailsOpen = false;
        clock.calendarOpen = false;
      }
    }

    Rectangle {
      id: barStrip

      z: 1
      width: parent.width
      height: Theme.barHeight
      color: Theme.bg
      border.color: Theme.border
      border.width: 1

      HoverHandler {
        onHoveredChanged: hovered ? bar.onEnter() : bar.onLeave()
      }

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.gap
        anchors.rightMargin: Theme.gap
        spacing: 0

        Workspaces {
          monitor: bar.monitor
        }

        Separator {
          visible: media.active
        }

        MediaPlayer {
          id: media

          tooltipHost: tooltip
        }

        Item {
          Layout.fillWidth: true
        }

        Notification {
          enabled: menu.notificationsEnabled
        }

        Item {
          Layout.fillWidth: true
        }

        RowLayout {
          spacing: Theme.itemSpacing

          Battery {
            id: battery

            panelHost: panelLayer
          }
          Clock {
            id: clock

            panelHost: panelLayer
          }
          Separator {}
          Tray {}

          AudioControl {
            node: Pipewire.defaultAudioSource
            isMicrophone: true
            visible: !muted
            tooltipHost: tooltip
          }

          BarButton {
            visible: menu.keepAwake
            icon: "changes-allow-symbolic"
            tooltip: "Activer la mise en veille"
            tooltipHost: tooltip
            onClicked: menu.setKeepAwake(false)
          }

          BarButton {
            id: menuButton

            icon: "view-more-symbolic"
            tooltip: "Menu"
            tooltipHost: tooltip
            checked: menu.open
            onClicked: menu.open = !menu.open
          }
        }
      }
    }

    Item {
      id: panelLayer

      anchors.fill: parent
      z: 2
    }

    Menu {
      id: menu

      tooltipHost: tooltip
      z: 2

      onOpenChanged: if (open)
        menu.x = Math.round(Math.max(4, Math.min(win.width - menu.width - 4, menuButton.mapToItem(win.contentItem, 0, 0).x + menuButton.width - menu.width)))

      y: Theme.barHeight + 4
    }

    Tooltip {
      id: tooltip

      z: 3
    }

    Connections {
      target: menu

      function onOpenChanged() {
        if (menu.open)
          bar.onEnter();
        else
          bar.onLeave();
      }
    }
  }

  PanelWindow {
    screen: bar.screen
    visible: bar.inKiosk && !bar.revealed
    implicitHeight: Theme.hoverZoneHeight
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    anchors {
      top: true
      left: true
      right: true
    }

    color: Qt.rgba(0, 0, 0, 0.01)

    HoverHandler {
      onHoveredChanged: if (hovered)
        bar.onEnter()
    }
  }
}
