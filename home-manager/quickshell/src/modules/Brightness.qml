import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import ".."

RowLayout {
  id: root

  property bool showSlider: false
  property Item tooltipHost: null

  property bool available: false
  property real brightness: 0

  spacing: 4
  Layout.alignment: Qt.AlignVCenter
  visible: root.available

  readonly property string icon: {
    if (brightness <= 0.01)
      return "display-brightness-off-symbolic";
    if (brightness <= 0.33)
      return "display-brightness-low-symbolic";
    if (brightness <= 0.66)
      return "display-brightness-medium-symbolic";
    return "display-brightness-high-symbolic";
  }

  function refresh() {
    queryProc.running = true;
  }

  Component.onCompleted: refresh()

  Item {
    implicitWidth: 30
    implicitHeight: 30
    Layout.alignment: Qt.AlignVCenter

    Icon {
      anchors.centerIn: parent
      icon: root.icon
      color: Theme.fg
      size: 16
    }
  }

  Slider {
    id: slider

    visible: root.showSlider
    Layout.fillWidth: true
    Layout.preferredWidth: 200
    Layout.alignment: Qt.AlignVCenter
    from: 1
    to: 100
    stepSize: 1
    wheelEnabled: true
    value: Math.round(root.brightness * 100)

    onMoved: {
      root.brightness = value / 100;
      setDebounce.restart();
    }

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
    text: Math.round(root.brightness * 100) + "%"
    color: Theme.fg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
  }

  Timer {
    id: setDebounce

    interval: 80
    onTriggered: {
      setProc.command = ["brightnessctl", "set", Math.round(root.brightness * 100) + "%"];
      setProc.running = true;
    }
  }

  Process {
    id: setProc
  }

  Process {
    id: queryProc

    command: ["brightnessctl", "-m", "i"]

    stdout: StdioCollector {
      onStreamFinished: {
        const fields = text.trim().split(",");
        const pct = fields.length >= 4 ? parseInt(fields[3]) : NaN;

        root.available = !isNaN(pct);
        if (root.available)
          root.brightness = pct / 100;
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }
}
