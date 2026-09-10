import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".."

ColumnLayout {
  id: root

  // "speakers" or "microphones"
  required property string kind

  signal picked
  readonly property bool isSink: kind === "speakers"
  readonly property var rules: audioRules.adapter?.[kind] ?? ({
      ignore: [],
      rename: {}
    })

  readonly property PwNode currentDefault: isSink ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource

  spacing: 2

  property string dumpText: ""
  readonly property var unavailable: root.parseDump(root.dumpText, root.isSink)

  function refresh() {
    dump.running = true;
  }

  Component.onCompleted: refresh()

  readonly property int nodeCount: Pipewire.nodes.values.length
  onNodeCountChanged: refresh()

  Process {
    id: dump

    command: ["pw-dump"]

    stdout: StdioCollector {
      onStreamFinished: root.dumpText = text
    }
  }

  function parseDump(text: string, isSink: bool): var {
    const hidden = [];
    let objs;
    try {
      objs = JSON.parse(text);
    } catch (e) {
      return hidden;
    }

    const direction = isSink ? "Output" : "Input";
    const mediaClass = isSink ? "Audio/Sink" : "Audio/Source";
    const deviceUsable = {};

    for (const o of objs) {
      if (!String(o.type ?? "").endsWith("Device"))
        continue;
      const routes = o.info?.params?.EnumRoute ?? [];
      deviceUsable[o.id] = routes.some(r => r.direction === direction && r.available !== "no");
    }

    for (const o of objs) {
      if (!String(o.type ?? "").endsWith("Node"))
        continue;
      const props = o.info?.props ?? {};
      if (props["media.class"] !== mediaClass)
        continue;
      const dev = props["device.id"];
      if (dev !== undefined && deviceUsable[dev] === false)
        hidden.push(props["node.name"]);
    }

    return hidden;
  }

  FileView {
    id: audioRules

    path: `${Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config"}/quickshell-audio.json`
    preload: true
    watchChanges: true
    printErrors: false
    onFileChanged: reload()

    JsonAdapter {
      property var speakers: ({
          ignore: [],
          rename: {}
        })
      property var microphones: ({
          ignore: [],
          rename: {}
        })
    }
  }

  function labelFor(node: PwNode): string {
    return root.rules.rename?.[node.name] ?? node.description ?? node.name ?? "";
  }

  Repeater {
    model: ScriptModel {
      values: [...Pipewire.nodes.values].filter(n => n.audio && !n.isStream && n.isSink === root.isSink && !(root.rules.ignore ?? []).includes(n.name) && !root.unavailable.includes(n.name))
    }

    delegate: Rectangle {
      id: row

      required property PwNode modelData
      readonly property bool active: root.currentDefault === modelData

      Layout.fillWidth: true
      implicitHeight: 26
      radius: Theme.radius
      color: {
        if (active)
          return Theme.alpha(Theme.fg, 0.22);
        if (rowHover.hovered)
          return Theme.alpha(Theme.fg, 0.12);
        return "transparent";
      }

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        spacing: 8

        Icon {
          opacity: row.active ? 1 : 0
          icon: "object-select-symbolic"
          size: 14
        }

        Text {
          Layout.fillWidth: true
          text: root.labelFor(row.modelData)
          elide: Text.ElideRight
          color: Theme.fg
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
        }
      }

      MouseArea {
        id: rowHover

        anchors.fill: parent
        hoverEnabled: true

        readonly property bool hovered: containsMouse

        onClicked: {
          if (root.isSink)
            Pipewire.preferredDefaultAudioSink = row.modelData;
          else
            Pipewire.preferredDefaultAudioSource = row.modelData;

          root.picked();
        }
      }
    }
  }
}
