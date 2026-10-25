import QtQuick
import QtQuick.Layouts
import ".."

ColumnLayout {
  id: root

  readonly property int maxRows: 5

  visible: Reminders.upcoming.length > 0
  spacing: 8

  Rectangle {
    Layout.fillWidth: true
    Layout.topMargin: 2
    implicitHeight: 1
    color: Theme.alpha(Theme.fg, 0.12)
  }

  Repeater {
    model: Reminders.upcoming.slice(0, root.maxRows)

    delegate: ColumnLayout {
      id: row

      required property var modelData

      Layout.fillWidth: true
      spacing: 0

      RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
          Layout.fillWidth: true
          text: {
            const [y, m, d] = row.modelData.date.split("-").map(Number);
            const day = Theme.formatDate(new Date(y, m - 1, d), "ddd d MMM");
            if (row.modelData.time < 0)
              return day;
            const hh = String(Math.floor(row.modelData.time / 60)).padStart(2, "0");
            const mm = String(row.modelData.time % 60).padStart(2, "0");
            return `${day} ${hh}:${mm}`;
          }
          color: Theme.alpha(Theme.fg, 0.7)
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize * 0.9
          font.bold: true
        }

        BarButton {
          icon: "x"
          implicitWidth: 22
          implicitHeight: 22
          onClicked: Reminders.removeReminder(row.modelData.line)
        }
      }

      Text {
        Layout.fillWidth: true
        text: row.modelData.text
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        elide: Text.ElideRight
      }
    }
  }
}
