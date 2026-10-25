import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import ".."

Item {
  id: root

  property bool calendarOpen: false
  property Item panelHost: null
  property Item tooltipHost: null

  readonly property date now: sysClock.date

  property string picker: ""
  property date selectedDate: new Date()
  property bool dialogOpen: false

  readonly property rect panelRect: Qt.rect(panel.x, panel.y, panel.width, panel.height)
  readonly property rect dialogRect: dialog.cardRect
  property int yearPage: 0

  readonly property int bodyWidth: 7 * 40 + 6 * 2
  readonly property int bodyHeight: 178

  implicitWidth: label.implicitWidth + 16
  implicitHeight: 28
  Layout.alignment: Qt.AlignVCenter

  onVisibleChanged: if (!visible)
    calendarOpen = false

  onCalendarOpenChanged: if (!calendarOpen)
    dialogOpen = false

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

  function hideTip() {
    tipDelay.stop();
    if (root.tooltipHost?.target === root)
      root.tooltipHost.hide();
  }

  Timer {
    id: tipDelay

    interval: 600
    onTriggered: {
      const d = new Date();
      const utc = new Date(d.getTime() + d.getTimezoneOffset() * 60000);
      root.tooltipHost?.show(root, Theme.formatDate(utc, "HH:mm - d MMM") + " UTC");
    }
  }

  Component.onDestruction: root.hideTip()

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
    text: Theme.formatDate(root.now, "HH:mm:ss - d MMM") + (Reminders.nextText.length > 0 ? `  ·  ${Reminders.nextText}` : "")
    color: Theme.fg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.bold: true
  }

  MouseArea {
    id: mouse

    anchors.fill: parent
    hoverEnabled: true
    onContainsMouseChanged: {
      if (containsMouse && !root.calendarOpen && root.tooltipHost)
        tipDelay.restart();
      else
        root.hideTip();
    }
    onClicked: {
      root.hideTip();
      if (!root.calendarOpen) {
        grid.month = root.now.getMonth();
        grid.year = root.now.getFullYear();
        root.picker = "";
        root.selectedDate = root.now;
        Reminders.reload();
      }
      root.calendarOpen = !root.calendarOpen;
      if (root.calendarOpen) {
        panel.place();
        panel.forceActiveFocus();
      }
    }
  }

  Rectangle {
    id: panel

    parent: root.panelHost ?? root
    visible: root.calendarOpen

    width: root.bodyWidth + 24
    height: header.implicitHeight + root.bodyHeight + 26 + extras.implicitHeight + 8
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
        icon: "chevron-left"
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
        icon: "chevron-right"
        implicitWidth: 24
        implicitHeight: 24
        onClicked: root.step(1)
      }
    }

    ReminderDialog {
      id: dialog

      parent: root.panelHost ?? root
      anchors.fill: parent
      z: 10
      visible: root.dialogOpen
      date: root.selectedDate
      centerX: panel.x + panel.width / 2
      topY: Theme.barHeight + 4
      onClose: root.dialogOpen = false
    }

    ColumnLayout {
      id: extras

      x: 12
      y: header.y + header.implicitHeight + 6 + root.bodyHeight + 8
      width: root.bodyWidth
      spacing: 8

      ClockTimers {
        Layout.fillWidth: true
      }

      ClockReminders {
        Layout.fillWidth: true
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

          locale: Theme.locale

          Layout.alignment: Qt.AlignHCenter
          month: root.now.getMonth()
          year: root.now.getFullYear()
          spacing: 2

          delegate: Rectangle {
            id: dayCell

            required property var model

            readonly property string key: Qt.formatDate(model.date, "yyyy-MM-dd")

            implicitWidth: 40
            implicitHeight: 24
            radius: Theme.radius
            color: model.today ? Theme.alpha(Theme.selectedBg, 0.35) : (dayHover.containsMouse ? Theme.alpha(Theme.fg, 0.12) : "transparent")
            border.width: key === Qt.formatDate(root.selectedDate, "yyyy-MM-dd") ? 1 : 0
            border.color: Theme.selectedBg

            Text {
              anchors.centerIn: parent
              text: model.day
              color: Theme.fg
              // Days spilling in from the neighbouring months.
              opacity: model.month === grid.month ? 1 : 0.35
              font.family: Theme.fontFamily
              font.pixelSize: Theme.fontSize
            }

            Rectangle {
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.bottom: parent.bottom
              anchors.bottomMargin: 2
              width: 4
              height: 4
              radius: 2
              color: Theme.fg
              visible: Reminders.days[dayCell.key] === true
            }

            MouseArea {
              id: dayHover

              anchors.fill: parent
              hoverEnabled: true
              onClicked: {
                root.selectedDate = dayCell.model.date;
                root.dialogOpen = true;
              }
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
