import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "."

PanelWindow {
  id: root

  property bool open: false
  property int index: 0
  property var windows: []

  readonly property int thumbWidth: 280
  readonly property int thumbHeight: 175

  screen: {
    for (const s of Quickshell.screens) {
      if (Hyprland.monitorFor(s) === Hyprland.focusedMonitor)
        return s;
    }
    return Quickshell.screens[0];
  }

  visible: open
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "quickshell-switcher"
  WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  function collect() {
    Hyprland.refreshToplevels();
    return [...Hyprland.toplevels.values].filter(t => t.wayland).sort((a, b) => (a.lastIpcObject?.focusHistoryID ?? 99) - (b.lastIpcObject?.focusHistoryID ?? 99));
  }

  function step(delta: int) {
    if (!open) {
      windows = collect();
      if (windows.length === 0)
        return;
      index = windows.length > 1 ? 1 : 0;
      open = true;
      if (delta > 0)
        return;
    }
    index = (index + delta + windows.length) % windows.length;
  }

  function confirm() {
    const target = windows[index]?.wayland;
    open = false;
    if (target)
      target.activate();
  }

  function cancel() {
    open = false;
  }

  Rectangle {
    anchors.fill: parent
    color: Theme.alpha("black", 0.45)

    MouseArea {
      anchors.fill: parent
      onClicked: root.cancel()
    }
  }

  Rectangle {
    id: panel

    anchors.centerIn: parent
    width: Math.min(row.implicitWidth + 2 * Theme.gap * 2, root.width - 80)
    height: row.implicitHeight + 2 * Theme.gap * 2
    radius: Theme.radius
    color: Theme.bg
    border.color: Theme.border
    border.width: 1

    ListView {
      id: row

      anchors.fill: parent
      anchors.margins: Theme.gap * 2
      orientation: ListView.Horizontal
      spacing: Theme.gap
      clip: true
      model: root.windows
      currentIndex: root.index
      implicitWidth: contentWidth
      implicitHeight: root.thumbHeight + 40
      highlightMoveDuration: 100

      delegate: Rectangle {
        id: card

        required property var modelData
        required property int index
        readonly property bool selected: index === root.index

        width: root.thumbWidth
        height: ListView.view.height
        radius: Theme.radius
        color: selected ? Theme.selectedBg : "transparent"

        ScreencopyView {
          anchors.top: parent.top
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.topMargin: Theme.gap
          width: root.thumbWidth - 2 * Theme.gap
          height: root.thumbHeight
          captureSource: card.modelData.wayland
          live: true
        }

        Text {
          anchors.bottom: parent.bottom
          anchors.bottomMargin: Theme.gap
          anchors.horizontalCenter: parent.horizontalCenter
          width: parent.width - 2 * Theme.gap
          horizontalAlignment: Text.AlignHCenter
          elide: Text.ElideRight
          text: card.modelData.title
          color: card.selected ? Theme.selectedFg : Theme.text
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
        }

        MouseArea {
          anchors.fill: parent
          onClicked: {
            root.index = card.index;
            root.confirm();
          }
        }
      }
    }
  }

  Item {
    focus: root.open
    Keys.onPressed: event => {
      if (event.key === Qt.Key_Tab || event.key === Qt.Key_Right || event.key === Qt.Key_L || event.key === Qt.Key_K)
        root.step(1);
      else if (event.key === Qt.Key_Backtab || event.key === Qt.Key_Left || event.key === Qt.Key_H || event.key === Qt.Key_J)
        root.step(-1);
      else if (event.key === Qt.Key_G)
        root.index = (event.modifiers & Qt.ShiftModifier) ? root.windows.length - 1 : 0;
      else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space)
        root.confirm();
      else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q)
        root.cancel();
    }
    Keys.onReleased: event => {
      if (event.key === Qt.Key_Super_L || event.key === Qt.Key_Super_R)
        root.confirm();
    }
  }
}
