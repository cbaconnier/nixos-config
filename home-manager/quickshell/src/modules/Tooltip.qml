import QtQuick
import ".."

Item {
  id: root

  property Item target: null
  readonly property bool shown: target !== null

  visible: shown
  implicitWidth: bg.width
  implicitHeight: bg.height

  function show(item: Item, text: string) {
    if (!item || !text)
      return;

    label.text = text;
    root.target = item;

    const p = item.mapToItem(root.parent, 0, 0);
    const max = root.parent.width - bg.width - 4;
    root.x = Math.round(Math.max(4, Math.min(max, p.x + item.width / 2 - bg.width / 2)));
    root.y = Math.round(p.y + item.height + 6);
  }

  function hide() {
    root.target = null;
  }

  Rectangle {
    id: bg

    width: label.implicitWidth + 16
    height: label.implicitHeight + 10
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: Theme.radius

    Text {
      id: label

      anchors.centerIn: parent
      color: Theme.fg
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }
  }
}
