pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool plugged: false
    property bool unlocked: false
    // A YubiKey already plugged at login doesn't open the PIN popup
    property bool ready: false
    // ssh waits for a touch (ssh-askpass-touch)
    property bool touchWaiting: false
    // pid of the ssh-askpass-touch showing the popup, signalled to deny the touch
    property int touchPid: 0

    readonly property var env: ({
            SSH_AUTH_SOCK: Quickshell.env("SSH_AUTH_SOCK") || `${Quickshell.env("XDG_RUNTIME_DIR")}/ssh-agent`
        })

    function unlock() {
        unlockProc.running = true;
    }

    function lock() {
        lockProc.running = true;
    }

    function setTouchWaiting(waiting: bool, pid: int) {
        // An older ssh-askpass-touch finishing doesn't hide a newer popup
        if (!waiting && pid && pid !== touchPid)
            return;
        touchPid = waiting ? pid : 0;
        touchWaiting = waiting;
    }

    function denyTouch() {
        if (touchPid)
            Quickshell.execDetached(["kill", "-USR1", String(touchPid)]);
        touchPid = 0;
        touchWaiting = false;
    }

    function refresh() {
        statusProc.running = true;
    }

    onPluggedChanged: if (plugged && ready && !unlocked)
        unlock()

    Process {
        id: statusProc

        // Yubico vendor id 1050, read from sysfs without opening the device
        command: ["sh", "-c", "cat /sys/class/hidraw/*/device/uevent 2>/dev/null | grep -c 'HID_ID=0003:00001050'; ssh-add -l 2>/dev/null | grep -c -- '-SK)'"]
        environment: root.env

        stdout: StdioCollector {
            onStreamFinished: {
                const [plugged, unlocked] = text.trim().split("\n").map(Number);
                root.unlocked = unlocked > 0;
                root.plugged = plugged > 0;
                root.ready = true;
            }
        }
    }

    Process {
        id: unlockProc

        command: ["yubikey-unlock"]
        onExited: root.refresh()
    }

    Process {
        id: lockProc

        command: ["ssh-add", "-D"]
        environment: root.env
        onExited: root.refresh()
    }

    // In case ssh-askpass-touch never says the touch is done
    Timer {
        interval: 30000
        running: root.touchWaiting
        onTriggered: root.setTouchWaiting(false, 0)
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
