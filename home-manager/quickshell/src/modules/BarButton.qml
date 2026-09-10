import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

Rectangle {
  id: button

  property string icon
  property real iconOpacity: 1
  property string tooltip
  property Item tooltipHost: null
  property bool checked: false
  property bool enabled: true
  property bool filled: false

  signal clicked

  Layout.alignment: Qt.AlignVCenter

  implicitWidth: filled ? 34 : 30
  implicitHeight: filled ? 30 : 30
  radius: Theme.radius
  opacity: enabled ? 1 : 0.6

  color: {
    if (checked)
      return Theme.alpha(Theme.fg, 0.22);
    if (hover.hovered && enabled)
      return Theme.alpha(Theme.fg, 0.12);
    return filled ? Theme.alpha(Theme.fg, 0.08) : "transparent";
  }

  border.width: filled && !checked ? 1 : 0
  border.color: Theme.alpha(Theme.fg, 0.12)

  Icon {
    x: Math.round((button.width - width) / 2)
    y: Math.round((button.height - height) / 2)
    icon: button.icon
    opacity: button.iconOpacity
    color: Theme.fg
    size: 16
  }

  MouseArea {
    id: hover

    anchors.fill: parent
    enabled: button.enabled
    hoverEnabled: true

    readonly property bool hovered: containsMouse

    onHoveredChanged: {
      if (hovered && button.tooltip && button.tooltipHost)
        tipDelay.restart();
      else {
        tipDelay.stop();
        if (button.tooltipHost?.target === button)
          button.tooltipHost.hide();
      }
    }

    onClicked: {
      tipDelay.stop();
      if (button.tooltipHost?.target === button)
        button.tooltipHost.hide();
      button.clicked();
    }
  }

  Timer {
    id: tipDelay

    interval: 600
    onTriggered: if (hover.hovered)
      button.tooltipHost.show(button, button.tooltip)
  }

  Component.onDestruction: if (button.tooltipHost?.target === button)
    button.tooltipHost.hide()
}
