import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

BarButton {
  id: root

  property bool awake: false
  property bool available: false

  visible: available
  icon: awake ? "changes-allow-symbolic" : "changes-prevent-symbolic"
  tooltip: awake ? "Activer la mise en veille" : "Désactiver la mise en veille"
  checked: awake
  iconOpacity: awake ? 0.29 : 1
  onClicked: root.apply(!root.awake)

  function apply(next: bool) {
    if (!root.available)
      return;

    root.awake = next;
    toggleProc.command = next ? ["systemctl", "--user", "stop", "hypridle"] : ["bash", "-c", "systemctl --user reset-failed hypridle; systemctl --user start hypridle"];
    toggleProc.running = true;
  }

  function refresh() {
    queryProc.running = true;
  }

  Component.onCompleted: refresh()

  Process {
    id: queryProc

    command: ["systemctl", "--user", "show", "hypridle", "-p", "LoadState", "-p", "ActiveState"]

    stdout: StdioCollector {
      onStreamFinished: {
        const props = {};
        for (const line of text.trim().split("\n")) {
          const eq = line.indexOf("=");
          if (eq > 0)
            props[line.slice(0, eq)] = line.slice(eq + 1).trim();
        }

        root.available = props["LoadState"] === "loaded";
        root.awake = root.available && props["ActiveState"] !== "active";
      }
    }
  }

  Process {
    id: toggleProc
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }
}
