import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import ".."

ColumnLayout {
    id: root

    property bool barIcon: false
    property Item tooltipHost: null
    property int threshold: 20

    readonly property var mice: UPower.devices.values.filter(d => d.type === UPowerDeviceType.Mouse && d.isPresent && !d.isLaptopBattery)
    readonly property var low: mice.filter(d => d.percentage * 100 <= threshold)

    function label(d): string {
        return `${d.model} — ${Math.round(d.percentage * 100)}%`;
    }

    visible: barIcon ? low.length > 0 : mice.length > 0
    spacing: 4

    BarButton {
        visible: root.barIcon
        icon: "battery-vertical-exclamation"
        tooltip: root.low.map(root.label).join("\n")
        tooltipHost: root.tooltipHost
    }

    Repeater {
        model: root.barIcon ? [] : root.mice

        RowLayout {
            required property var modelData

            Layout.fillWidth: true
            spacing: 16

            Text {
                Layout.fillWidth: true
                text: modelData.model
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            Text {
                text: Math.round(modelData.percentage * 100) + "%"
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }
    }
}
