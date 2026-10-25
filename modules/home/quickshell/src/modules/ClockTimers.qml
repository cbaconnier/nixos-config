import QtQuick
import QtQuick.Layouts
import ".."

ColumnLayout {
  id: root

  property bool customOpen: false

  spacing: 8

  function submit(raw: string) {
    const m = raw.trim().match(/^(\d+(?::\d+)?:\d+|\d+(?:[.,]\d+)?)\s*(.*)$/);
    if (!m)
      return false;
    const minutes = m[1].includes(":") ? m[1].split(":").reduce((acc, part) => acc * 60 + Number(part), 0) / 60 : parseFloat(m[1].replace(",", "."));
    Reminders.startTimer(minutes, m[2]);
    return true;
  }

  Rectangle {
    Layout.fillWidth: true
    Layout.topMargin: 2
    implicitHeight: 1
    color: Theme.alpha(Theme.fg, 0.12)
  }

  RowLayout {
    Layout.fillWidth: true
    spacing: 6

    Repeater {
      model: [5, 10, 15, 30]

      delegate: Rectangle {
        id: pill

        required property int modelData

        Layout.fillWidth: true
        implicitHeight: 30
        radius: Theme.radius
        color: pillHover.containsMouse ? Theme.alpha(Theme.fg, 0.18) : Theme.alpha(Theme.fg, 0.08)

        Text {
          anchors.centerIn: parent
          text: pill.modelData
          color: Theme.fg
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
        }

        MouseArea {
          id: pillHover

          anchors.fill: parent
          hoverEnabled: true
          onClicked: Reminders.startTimer(pill.modelData, "")
        }
      }
    }

    Rectangle {
      implicitWidth: 36
      implicitHeight: 30
      radius: Theme.radius
      color: {
        if (root.customOpen)
          return Theme.selectedBg;
        return plusHover.containsMouse ? Theme.alpha(Theme.fg, 0.18) : Theme.alpha(Theme.fg, 0.08);
      }

      Text {
        anchors.centerIn: parent
        text: "+"
        color: root.customOpen ? Theme.selectedFg : Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize * 1.3
        font.bold: true
      }

      MouseArea {
        id: plusHover

        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
          root.customOpen = !root.customOpen;
          if (root.customOpen)
            input.forceActiveFocus();
        }
      }
    }
  }

  Rectangle {
    Layout.fillWidth: true
    visible: root.customOpen
    implicitHeight: 32
    radius: Theme.radius
    color: Theme.alpha(Theme.fg, 0.08)
    border.width: input.activeFocus ? 1 : 0
    border.color: Theme.selectedBg

    TextInput {
      id: input

      anchors.fill: parent
      anchors.leftMargin: 12
      anchors.rightMargin: 12
      verticalAlignment: TextInput.AlignVCenter
      color: Theme.fg
      selectByMouse: true
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
      clip: true
      onAccepted: if (root.submit(text)) {
        text = "";
        root.customOpen = false;
      }
      Keys.onEscapePressed: {
        text = "";
        root.customOpen = false;
      }

      Text {
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        visible: input.text.length === 0
        text: "(hh:)mm:ss label"
        color: Theme.alpha(Theme.fg, 0.4)
        font: input.font
      }
    }
  }

  Repeater {
    model: Reminders.timers

    delegate: RowLayout {
      id: row

      required property int index
      required property string label
      required property real endsAt

      Layout.fillWidth: true
      spacing: 6

      Text {
        Layout.fillWidth: true
        text: row.label.length > 0 ? row.label : "Minuteur"
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        elide: Text.ElideRight
      }

      Text {
        text: Reminders.format(row.endsAt - Reminders.now)
        color: Theme.alpha(Theme.fg, 0.8)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: true
      }

      BarButton {
        icon: "x"
        implicitWidth: 22
        implicitHeight: 22
        onClicked: Reminders.cancelTimer(row.index)
      }
    }
  }
}
