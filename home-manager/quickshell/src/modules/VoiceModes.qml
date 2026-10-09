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

  readonly property var voices: ["banshee", "dragon", "double-entity", "storyteller"]
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

  BarButton {
    icon: "ear-hearing"
    tooltip: root.listening ? "Ne plus s'écouter" : "S'écouter"
    tooltipHost: root.tooltipHost
    checked: root.listening
    onClicked: root.toggleListen()
  }

  Separator {}

  Repeater {
    model: [
      {
        mode: "default",
        icon: "microphone-variant",
        tip: "Default"
      },
      {
        mode: "storyteller",
        icon: "book-open-page-variant",
        tip: "Storyteller"
      },
      {
        mode: "double-entity",
        icon: "ufo-outline",
        tip: "Double Entity"
      },
      {
        mode: "dragon",
        icon: "fire",
        tip: "Dragon"
      },
      {
        mode: "banshee",
        icon: "ghost",
        tip: "Banshee"
      }
    ]

    BarButton {
      required property var modelData

      icon: modelData.icon
      tooltip: modelData.tip
      tooltipHost: root.tooltipHost
      checked: root.mode === modelData.mode
      enabled: !modeProc.running
      onClicked: root.switchTo(modelData.mode)
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
