import QtQuick
import Quickshell
import Quickshell.Io
import ".."

BarButton {
  id: root

  property bool on: false

  icon: "sunset-2"
  tooltip: on ? "Désactiver le filtre lumière chaude" : "Activer le filtre lumière chaude"
  checked: on
  onClicked: root.apply(!root.on)

  function apply(next: bool) {
    root.on = next;
    toggleProc.command = next ? ["hyprsunset", "-t", "4000"] : ["pkill", "-x", "hyprsunset"];
    toggleProc.startDetached();
  }

  function refresh() {
    queryProc.running = true;
  }

  Component.onCompleted: refresh()

  Process {
    id: toggleProc
  }

  Process {
    id: queryProc

    command: ["pgrep", "-x", "hyprsunset"]

    stdout: StdioCollector {
      onStreamFinished: root.on = text.trim().length > 0
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }
}
