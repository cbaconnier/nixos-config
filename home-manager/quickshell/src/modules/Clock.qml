import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import ".."

Item {
  id: root

  property bool calendarOpen: false
  property Item panelHost: null

  readonly property date now: sysClock.date

  property string picker: ""
  property int yearPage: 0

  readonly property int bodyWidth: 7 * 28 + 6 * 2
  readonly property int bodyHeight: 178

  implicitWidth: label.implicitWidth + 16
  implicitHeight: 28
  Layout.alignment: Qt.AlignVCenter

  onVisibleChanged: if (!visible)
    calendarOpen = false

  function step(delta: int) {
    if (root.picker === "year") {
      root.yearPage += delta * 12;
      return;
    }

    if (root.picker === "month") {
      grid.year += delta;
      return;
    }

    const m = grid.month + delta;
    if (m < 0) {
      grid.month = 11;
      grid.year -= 1;
    } else if (m > 11) {
      grid.month = 0;
      grid.year += 1;
    } else
      grid.month = m;
  }

  SystemClock {
    id: sysClock

    precision: SystemClock.Seconds
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.radius
    color: {
      if (root.calendarOpen)
        return Theme.alpha(Theme.fg, 0.22);
      if (mouse.containsMouse)
        return Theme.alpha(Theme.fg, 0.12);
      return "transparent";
    }
  }

  Text {
    id: label

    anchors.centerIn: parent
    text: Qt.formatDateTime(root.now, "HH:mm:ss - d MMM.")
    color: Theme.fg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.bold: true
  }

  MouseArea {
    id: mouse

    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
      if (!root.calendarOpen) {
        grid.month = root.now.getMonth();
        grid.year = root.now.getFullYear();
        root.picker = "";
      }
      root.calendarOpen = !root.calendarOpen;
      if (root.calendarOpen)
        panel.place();
    }
  }

  Rectangle {
    id: panel

    parent: root.panelHost ?? root
    visible: root.calendarOpen

    width: root.bodyWidth + 24
    height: header.implicitHeight + root.bodyHeight + 26
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: Theme.radius

    function place() {
      const host = root.panelHost;
      if (!host)
        return;

      const origin = root.mapToItem(host, 0, 0);
      const centred = origin.x + (root.width - panel.width) / 2;
      panel.x = Math.round(Math.max(4, Math.min(host.width - panel.width - 4, centred)));
      panel.y = Theme.barHeight + 4;
    }

    MouseArea {
      anchors.fill: parent
    }

    RowLayout {
      id: header

      x: 12
      y: 10
      width: root.bodyWidth
      spacing: 4

      BarButton {
        icon: "pan-start-symbolic"
        implicitWidth: 24
        implicitHeight: 24
        onClicked: root.step(-1)
      }

      Item {
        Layout.fillWidth: true
      }

      HeaderLabel {
        visible: root.picker !== "year"
        text: grid.locale.standaloneMonthName(grid.month)
        active: root.picker === "month"
        onClicked: root.picker = root.picker === "month" ? "" : "month"
      }

      HeaderLabel {
        text: root.picker === "year" ? `${root.yearPage} – ${root.yearPage + 11}` : String(grid.year)
        active: root.picker === "year"
        onClicked: {
          if (root.picker === "year")
            root.picker = "";
          else {
            root.yearPage = grid.year - 5;
            root.picker = "year";
          }
        }
      }

      Item {
        Layout.fillWidth: true
      }

      BarButton {
        icon: "pan-end-symbolic"
        implicitWidth: 24
        implicitHeight: 24
        onClicked: root.step(1)
      }
    }

    Item {
      id: body

      x: 12
      y: header.y + header.implicitHeight + 6
      width: root.bodyWidth
      height: root.bodyHeight

      ColumnLayout {
        anchors.fill: parent
        visible: root.picker === ""
        spacing: 4

        DayOfWeekRow {
          Layout.fillWidth: true
          locale: grid.locale

          delegate: Text {
            required property var model

            horizontalAlignment: Text.AlignHCenter
            text: model.shortName
            color: Theme.fg
            opacity: 0.6
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize * 0.8
          }
        }

        MonthGrid {
          id: grid

          Layout.alignment: Qt.AlignHCenter
          month: root.now.getMonth()
          year: root.now.getFullYear()
          spacing: 2

          delegate: Rectangle {
            required property var model

            implicitWidth: 28
            implicitHeight: 24
            radius: Theme.radius
            color: model.today ? Theme.alpha(Theme.selectedBg, 0.35) : "transparent"

            Text {
              anchors.centerIn: parent
              text: model.day
              color: Theme.fg
              // Days spilling in from the neighbouring months.
              opacity: model.month === grid.month ? 1 : 0.35
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize
            }
          }
        }
      }

      Grid {
        anchors.fill: parent
        visible: root.picker === "month"
        columns: 3
        rows: 4
        spacing: 2

        Repeater {
          model: 12

          delegate: PickerCell {
            required property int index

            width: (body.width - 4) / 3
            height: (body.height - 6) / 4
            text: grid.locale.standaloneMonthName(index, Locale.ShortFormat)
            current: index === grid.month
            onClicked: {
              grid.month = index;
              root.picker = "";
            }
          }
        }
      }

      Grid {
        anchors.fill: parent
        visible: root.picker === "year"
        columns: 3
        rows: 4
        spacing: 2

        Repeater {
          model: 12

          delegate: PickerCell {
            required property int index

            readonly property int value: root.yearPage + index

            width: (body.width - 4) / 3
            height: (body.height - 6) / 4
            text: String(value)
            current: value === grid.year
            onClicked: {
              grid.year = value;
              root.picker = "";
            }
          }
        }
      }
    }
  }

  component HeaderLabel: Rectangle {
    id: headerLabel

    property alias text: headerText.text
    property bool active: false

    signal clicked

    implicitWidth: headerText.implicitWidth + 12
    implicitHeight: headerText.implicitHeight + 6
    radius: Theme.radius
    color: {
      if (headerLabel.active)
        return Theme.alpha(Theme.fg, 0.22);
      if (headerHover.containsMouse)
        return Theme.alpha(Theme.fg, 0.12);
      return "transparent";
    }

    Text {
      id: headerText

      anchors.centerIn: parent
      color: Theme.fg
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
      font.bold: true
    }

    MouseArea {
      id: headerHover

      anchors.fill: parent
      hoverEnabled: true
      onClicked: headerLabel.clicked()
    }
  }

  component PickerCell: Rectangle {
    id: cell

    property alias text: cellText.text
    property bool current: false

    signal clicked

    radius: Theme.radius
    color: {
      if (cell.current)
        return Theme.alpha(Theme.selectedBg, 0.35);
      if (cellHover.containsMouse)
        return Theme.alpha(Theme.fg, 0.12);
      return "transparent";
    }

    Text {
      id: cellText

      anchors.centerIn: parent
      color: Theme.fg
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }

    MouseArea {
      id: cellHover

      anchors.fill: parent
      hoverEnabled: true
      onClicked: cell.clicked()
    }
  }
}
