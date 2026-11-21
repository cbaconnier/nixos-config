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
    margins.top: Theme.barHeight + Theme.gap - halo

    // Room for the pulsing halo around the card
    readonly property int halo: 12

    implicitWidth: card.width + halo * 2
    implicitHeight: card.height + halo * 2

    // Pulsing halo
    Rectangle {
        anchors.centerIn: card
        width: card.width + root.halo * 2 * pulse
        height: card.height + root.halo * 2 * pulse
        radius: Theme.radius + root.halo * pulse
        color: "transparent"
        border.color: Theme.selectedBg
        border.width: 2
        opacity: 0.8 * (1 - pulse)

        property real pulse: 0

        NumberAnimation on pulse {
            running: root.visible
            from: 0
            to: 1
            duration: 1600
            loops: Animation.Infinite
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: card

        anchors.centerIn: parent
        width: row.implicitWidth + 32
        height: row.implicitHeight + 24
        color: Theme.bg
        border.color: Theme.selectedBg
        border.width: 1
        radius: Theme.radius

        RowLayout {
            id: row

            anchors.centerIn: parent
            spacing: 12

            Icon {
                icon: "lock-key"
                size: 22
                color: Theme.selectedBg
            }

            Text {
                text: "Touch your YubiKey"
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 16
            }

            Item {
                implicitWidth: 8
            }

            Rectangle {
                implicitWidth: denyText.implicitWidth + 24
                implicitHeight: 30
                radius: Theme.radius
                color: denyHover.containsMouse ? Theme.alpha(Theme.destructive, 0.25) : Theme.alpha(Theme.fg, 0.08)

                Text {
                    id: denyText

                    anchors.centerIn: parent
                    text: "Deny"
                    color: denyHover.containsMouse ? Theme.destructive : Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                MouseArea {
                    id: denyHover

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: YubiKey.denyTouch()
                }
            }
        }
    }
}
