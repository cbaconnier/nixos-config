import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import ".."

Item {
  id: root

  readonly property UPowerDevice bat: UPower.displayDevice
  readonly property bool present: bat.ready && bat.isLaptopBattery && bat.isPresent
  readonly property bool full: bat.state === UPowerDeviceState.FullyCharged || bat.state === UPowerDeviceState.PendingCharge
  readonly property string pct: Math.round(bat.percentage * 100) + "%"
  property bool detailsOpen: false
  property Item panelHost: null

  visible: present
  implicitWidth: row.implicitWidth + 16
  implicitHeight: 28
  Layout.alignment: Qt.AlignVCenter

  onVisibleChanged: if (!visible)
    detailsOpen = false

  function formatTime(seconds: real): string {
    if (seconds <= 0)
      return "";
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    return h > 0 ? `${h}h${String(m).padStart(2, "0")}m` : `${m}m`;
  }

  function stateName(state): string {
    switch (state) {
    case UPowerDeviceState.Charging:
      return "Charge";
    case UPowerDeviceState.Discharging:
      return "Décharge";
    case UPowerDeviceState.Empty:
      return "Vide";
    case UPowerDeviceState.FullyCharged:
      return "Pleine";
    case UPowerDeviceState.PendingCharge:
    case UPowerDeviceState.PendingDischarge:
      return "En attente";
    default:
      return "Inconnu";
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.radius
    color: {
      if (root.detailsOpen)
        return Theme.alpha(Theme.fg, 0.22);
      if (mouse.containsMouse)
        return Theme.alpha(Theme.fg, 0.12);
      return "transparent";
    }
  }

  RowLayout {
    id: row

    anchors.centerIn: parent
    spacing: 4

    Icon {
      Layout.alignment: Qt.AlignVCenter
      icon: root.bat.iconName
    }

    Text {
      Layout.alignment: Qt.AlignVCenter
      visible: !root.full
      text: root.pct
      color: Theme.fg
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
      font.bold: true
    }
  }

  MouseArea {
    id: mouse

    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
      root.detailsOpen = !root.detailsOpen;
      if (root.detailsOpen)
        details.place();
    }
  }

  Rectangle {
    id: details

    parent: root.panelHost ?? root
    visible: root.detailsOpen

    width: rows.implicitWidth + 24
    height: rows.implicitHeight + 16
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: Theme.radius

    function place() {
      const host = root.panelHost;
      if (!host)
        return;

      const origin = root.mapToItem(host, 0, 0);
      const aligned = origin.x + root.width - details.width;
      details.x = Math.round(Math.max(4, Math.min(host.width - details.width - 4, aligned)));
      details.y = Theme.barHeight + 4;
    }

    MouseArea {
      anchors.fill: parent
    }

    ColumnLayout {
      id: rows

      x: 12
      y: 8
      spacing: 4

      InfoRow {
        label: "État"
        value: root.stateName(root.bat.state)
      }
      InfoRow {
        label: "Batterie"
        value: root.pct
      }
      InfoRow {
        label: "Autonomie"
        value: root.formatTime(root.bat.timeToEmpty)
        visible: root.bat.state === UPowerDeviceState.Discharging
      }
      InfoRow {
        label: "Charge complète"
        value: root.formatTime(root.bat.timeToFull)
        visible: root.bat.state === UPowerDeviceState.Charging
      }
      InfoRow {
        label: "Consommation"
        value: root.bat.changeRate.toFixed(1) + " W"
        visible: root.bat.changeRate > 0
      }
    }
  }

  component InfoRow: RowLayout {
    id: infoRow

    property string label
    property string value

    Layout.preferredWidth: 225
    spacing: 16

    Text {
      Layout.fillWidth: true
      text: infoRow.label
      color: Theme.fg
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }

    Text {
      text: infoRow.value
      color: Theme.fg
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize
    }
  }
}
