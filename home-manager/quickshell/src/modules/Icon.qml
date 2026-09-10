import QtQuick
import QtQuick.Effects
import Quickshell
import ".."

Item {
  id: root

  property string icon
  property color color: Theme.fg
  property int size: 16

  implicitWidth: size
  implicitHeight: size

  Image {
    id: img

    anchors.fill: parent
    source: root.icon ? Quickshell.iconPath(root.icon, true) : ""
    sourceSize.width: root.size
    sourceSize.height: root.size
    fillMode: Image.PreserveAspectFit
    smooth: true
    visible: false
  }

  Rectangle {
    anchors.fill: parent
    color: root.color
    visible: img.status === Image.Ready

    layer.enabled: true
    layer.effect: MultiEffect {
      maskEnabled: true
      maskSource: img
      maskThresholdMin: 0.5
      maskSpreadAtMin: 1
    }
  }
}
