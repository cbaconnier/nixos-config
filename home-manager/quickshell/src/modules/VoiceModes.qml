import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".."

RowLayout {
  id: root

  property Item tooltipHost: null
  property bool listening: false

  readonly property var voices: ["banshee", "dragon", "double-entity", "storyteller", "ghost", "walkie-talkie", "robot", "imp", "oracle", "ogre"]
  readonly property string sourceName: Pipewire.defaultAudioSource?.name ?? ""
  readonly property string mode: voices.find(v => sourceName === v + "_source") ?? "default"

  spacing: 6

  function refresh() {
    queryProc.running = true;
  }

  function switchTo(next: string) {
    modeProc.command = ["voice-mode", next];
    modeProc.running = true;
  }

  function toggleListen() {
    listenProc.command = ["voice", root.listening ? "unlisten" : "listen"];
    listenProc.running = true;
    root.listening = !root.listening;
  }

  Component.onCompleted: refresh()

  readonly property var modes: [
    {
      mode: "default",
      icon: "user",
      tip: "Default"
    },
    {
      mode: "storyteller",
      icon: "book-2",
      tip: "Storyteller"
    },
    {
      mode: "double-entity",
      icon: "brain",
      tip: "Double Entity"
    },
    {
      mode: "dragon",
      icon: "dragon",
      tip: "Dragon"
    },
    {
      mode: "banshee",
      icon: "droplet",
      tip: "Banshee"
    },
    {
      mode: "ghost",
      icon: "ghost-2",
      tip: "Ghost"
    },
    {
      mode: "walkie-talkie",
      icon: "radio",
      tip: "Walkie-talkie"
    },
    {
      mode: "robot",
      icon: "robot",
      tip: "Robot"
    },
    {
      mode: "imp",
      icon: "wand",
      tip: "Imp"
    },
    {
      mode: "oracle",
      icon: "crystal-ball",
      tip: "Oracle"
    },
    {
      mode: "ogre",
      icon: "axe",
      tip: "Ogre"
    }
  ]

  component ModeButton: BarButton {
    required property var modelData

    icon: modelData.icon
    tooltip: modelData.tip
    tooltipHost: root.tooltipHost
    checked: root.mode === modelData.mode
    enabled: !modeProc.running
    onClicked: root.switchTo(modelData.mode)
  }

  BarButton {
    icon: "headphones"
    tooltip: root.listening ? "Ne plus s'écouter" : "S'écouter"
    tooltipHost: root.tooltipHost
    checked: root.listening
    onClicked: root.toggleListen()
  }

  Separator {
    Layout.preferredHeight: 50
  }

  ColumnLayout {
    spacing: 6

    RowLayout {
      spacing: 6

      Repeater {
        model: root.modes.slice(0, 6)

        ModeButton {}
      }
    }

    RowLayout {
      spacing: 6

      Repeater {
        model: root.modes.slice(6)

        ModeButton {}
      }
    }
  }

  Process {
    id: modeProc
  }

  Process {
    id: listenProc

    onRunningChanged: if (!running)
      root.refresh()
  }

  Process {
    id: queryProc

    command: ["systemctl", "--user", "is-active", "voice-listen"]

    stdout: StdioCollector {
      onStreamFinished: root.listening = text.trim() === "active"
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }
}
