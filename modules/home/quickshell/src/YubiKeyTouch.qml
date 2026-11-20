import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "."
import "modules"

// Shown while ssh waits for a YubiKey touch
PanelWindow {
    id: root

    visible: YubiKey.touchWaiting

    screen: {
        for (const s of Quickshell.screens) {
            if (Hyprland.monitorFor(s) === Hyprland.focusedMonitor)
                return s;
        }
        return Quickshell.screens[0];
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-yubikey"
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    anchors.top: true
    margins.top: Theme.barHeight + Theme.gap

    implicitWidth: card.width
    implicitHeight: card.height

    Rectangle {
        id: card

        width: row.implicitWidth + 32
        height: row.implicitHeight + 20
        color: Theme.bg
        border.color: Theme.border
        border.width: 1
        radius: Theme.radius

        RowLayout {
            id: row

            anchors.centerIn: parent
            spacing: 10

            Icon {
                icon: "lock-key"
                size: 18
            }

            Text {
                text: "Waiting for YubiKey"
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }
    }
}
