import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import ".."

RowLayout {
  spacing: 2

  Repeater {
    model: SystemTray.items

    delegate: Rectangle {
      id: entry

      required property SystemTrayItem modelData

      implicitWidth: 26
      implicitHeight: 26
      radius: Theme.radius

      color: {
        if (mouse.pressed)
          return Theme.alpha(Theme.fg, 0.22);
        if (mouse.containsMouse)
          return Theme.alpha(Theme.fg, 0.12);
        return "transparent";
      }

      Image {
        anchors.centerIn: parent
        width: 18
        height: 18
        sourceSize.width: 18
        sourceSize.height: 18
        source: entry.modelData.icon
        fillMode: Image.PreserveAspectFit
        smooth: true
      }

      MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: mouse => {
          if (mouse.button === Qt.RightButton)
            entry.openMenu();
          else if (mouse.button === Qt.MiddleButton)
            entry.modelData.secondaryActivate();
          else if (entry.modelData.onlyMenu)
            entry.openMenu();
          else
            entry.modelData.activate();
        }
      }

      function openMenu() {
        if (!entry.modelData.hasMenu)
          return;

        const p = entry.mapToItem(null, 0, entry.height);
        entry.modelData.display(QsWindow.window, Math.round(p.x), Math.round(p.y));
      }
    }
  }
}
