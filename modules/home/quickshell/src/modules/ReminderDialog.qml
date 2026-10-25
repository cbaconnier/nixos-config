import QtQuick
import QtQuick.Layouts
import ".."

Item {
  id: root

  required property date date
  property real centerX: width / 2
  property real topY: Theme.barHeight

  property real offsetX: 0
  property real offsetY: 0

  readonly property int cardWidth: 460
  readonly property var parsedTime: timeField.text.match(/^(\d{1,2}):(\d{2})$/)
  readonly property bool timeValid: parsedTime !== null && Number(parsedTime[1]) < 24 && Number(parsedTime[2]) < 60
  readonly property bool valid: timeValid && labelField.text.trim().length > 0
  readonly property string relative: {
    const key = d => Qt.formatDate(d, "yyyy-MM-dd");
    const now = new Date();
    if (key(root.date) === key(now))
      return "Aujourd'hui";
    const tomorrow = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
    return key(root.date) === key(tomorrow) ? "Demain" : "";
  }

  readonly property rect cardRect: Qt.rect(card.x, card.y, card.width, card.height)

  signal close

  onVisibleChanged: {
    if (!visible)
      return;
    root.offsetX = 0;
    root.offsetY = 0;
    const now = new Date();
    timeField.text = root.relative === "Aujourd'hui" ? `${String((now.getHours() + 1) % 24).padStart(2, "0")}:00` : "09:00";
    labelField.text = "";
    timeField.forceActiveFocus();
    timeField.selectAll();
  }

  function submit() {
    if (!root.valid)
      return;
    Reminders.addReminder(Qt.formatDate(root.date, "yyyy-MM-dd"), `${root.parsedTime[1].padStart(2, "0")}:${root.parsedTime[2]}`, labelField.text);
    root.close();
  }

  Keys.onEscapePressed: root.close()

  Rectangle {
    id: card

    x: Math.round(Math.max(0, Math.min(root.width - width, root.centerX - width / 2 + root.offsetX)))
    y: Math.round(Math.max(0, Math.min(root.height - height, root.topY + root.offsetY)))
    width: root.cardWidth
    height: form.implicitHeight + 40
    radius: Theme.radius
    color: Theme.bg
    border.width: 1
    border.color: Theme.border

    MouseArea {
      anchors.fill: parent
    }

    ColumnLayout {
      id: form

      x: 20
      y: 20
      width: parent.width - 40
      spacing: 16

      RowLayout {
        Layout.fillWidth: true
        spacing: 16

        ColumnLayout {
          id: header

          Layout.fillWidth: true
          spacing: 0

          HoverHandler {
            cursorShape: Qt.SizeAllCursor
          }

          DragHandler {
            property real startX
            property real startY

            target: null
            onActiveChanged: {
              if (active) {
                startX = root.offsetX;
                startY = root.offsetY;
              }
            }
            onTranslationChanged: {
              root.offsetX = startX + translation.x;
              root.offsetY = startY + translation.y;
            }
          }

          Text {
            visible: root.relative.length > 0
            text: root.relative.toUpperCase()
            color: Theme.alpha(Theme.fg, 0.55)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize * 0.8
            font.bold: true
            font.letterSpacing: 1
          }

          Text {
            Layout.fillWidth: true
            text: Theme.formatDate(root.date, "dddd d")
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize * 1.3
            font.bold: true
            elide: Text.ElideRight
          }

          Text {
            Layout.fillWidth: true
            text: Theme.formatDate(root.date, "MMMM yyyy")
            color: Theme.alpha(Theme.fg, 0.7)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
          }
        }

        Rectangle {
          Layout.alignment: Qt.AlignVCenter
          implicitWidth: 104
          implicitHeight: 44
          radius: Theme.radius
          color: Theme.alpha(Theme.fg, 0.08)
          border.width: timeField.activeFocus || !root.timeValid ? 1 : 0
          border.color: root.timeValid ? Theme.selectedBg : Theme.destructive

          TextInput {
            id: timeField

            anchors.fill: parent
            anchors.margins: 4
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.fg
            selectByMouse: true
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize * 1.3
            font.bold: true
            KeyNavigation.tab: labelField
            onAccepted: labelField.forceActiveFocus()
          }
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 36
          radius: Theme.radius
          color: Theme.alpha(Theme.fg, 0.08)
          border.width: labelField.activeFocus ? 1 : 0
          border.color: Theme.selectedBg

          TextInput {
            id: labelField

            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.fg
            selectByMouse: true
            clip: true
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            KeyNavigation.tab: timeField
            onAccepted: root.submit()

            Text {
              anchors.fill: parent
              verticalAlignment: Text.AlignVCenter
              visible: labelField.text.length === 0
              text: "Label"
              color: Theme.alpha(Theme.fg, 0.4)
              font: labelField.font
            }
          }
        }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Item {
          Layout.fillWidth: true
        }

        Rectangle {
          implicitWidth: cancelText.implicitWidth + 32
          implicitHeight: 36
          radius: Theme.radius
          color: cancelHover.containsMouse ? Theme.alpha(Theme.fg, 0.18) : Theme.alpha(Theme.fg, 0.08)

          Text {
            id: cancelText

            anchors.centerIn: parent
            text: "Annuler"
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
          }

          MouseArea {
            id: cancelHover

            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.close()
          }
        }

        Rectangle {
          implicitWidth: addText.implicitWidth + 32
          implicitHeight: 36
          radius: Theme.radius
          opacity: root.valid ? 1 : 0.5
          color: addHover.containsMouse && root.valid ? Qt.lighter(Theme.selectedBg, 1.1) : Theme.selectedBg

          Text {
            id: addText

            anchors.centerIn: parent
            text: "Ajouter"
            color: Theme.selectedFg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
          }

          MouseArea {
            id: addHover

            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.submit()
          }
        }
      }
    }
  }
}
