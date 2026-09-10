import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import ".."

RowLayout {
  id: root

  property PwNode node
  property bool showSlider: false
  property bool isMicrophone: false
  property Item tooltipHost: null

  readonly property bool muted: node?.audio?.muted ?? false
  readonly property real volume: node?.audio?.volume ?? 0

  spacing: 4
  Layout.alignment: Qt.AlignVCenter

  PwObjectTracker {
    objects: root.node ? [root.node] : []
  }

  readonly property string icon: {
    if (isMicrophone) {
      if (muted)
        return "microphone-sensitivity-muted-symbolic";
      if (volume <= 0.33)
        return "microphone-sensitivity-low-symbolic";
      if (volume <= 0.66)
        return "microphone-sensitivity-medium-symbolic";
      return "microphone-sensitivity-high-symbolic";
    }
    if (muted)
      return "audio-volume-muted-symbolic";
    if (volume <= 0.33)
      return "audio-volume-low-symbolic";
    if (volume <= 0.66)
      return "audio-volume-medium-symbolic";
    return "audio-volume-high-symbolic";
  }

  BarButton {
    icon: root.icon
    tooltipHost: root.tooltipHost
    tooltip: root.isMicrophone ? (root.muted ? "Réactiver le micro" : "Couper le micro") : (root.muted ? "Réactiver le son" : "Couper le son")
    enabled: root.node !== null
    onClicked: if (root.node?.audio)
      root.node.audio.muted = !root.node.audio.muted
  }

  Slider {
    id: slider

    visible: root.showSlider
    Layout.fillWidth: true
    Layout.preferredWidth: 200
    Layout.alignment: Qt.AlignVCenter
    from: 0
    to: 1
    stepSize: 0.01
    wheelEnabled: true
    value: root.volume
    onMoved: if (root.node?.audio)
      root.node.audio.volume = value

    background: Rectangle {
      x: slider.leftPadding
      y: slider.topPadding + slider.availableHeight / 2 - height / 2
      width: slider.availableWidth
      height: 4
      radius: 2
      color: Theme.alpha(Theme.fg, 0.2)

      Rectangle {
        width: slider.visualPosition * parent.width
        height: parent.height
        radius: parent.radius
        color: Theme.selectedBg
      }
    }

    handle: Rectangle {
      x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
      y: slider.topPadding + slider.availableHeight / 2 - height / 2
      implicitWidth: 14
      implicitHeight: 14
      radius: width / 2
      color: slider.pressed ? Theme.selectedBg : Theme.bg
      border.width: 2
      border.color: Theme.selectedBg
    }
  }

  Text {
    visible: root.showSlider
    Layout.alignment: Qt.AlignVCenter
    text: Math.round(root.volume * 100) + "%"
    color: Theme.fg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
  }
}
