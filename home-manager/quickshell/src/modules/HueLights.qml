import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import ".."

BarButton {
  id: root

  property Item panelHost: null
  property bool panelOpen: false
  property string roomId: ""
  property string section: "scenes"
  property string expandedLight: ""

  readonly property int panelWidth: 340
  readonly property int contentWidth: panelWidth - 20
  readonly property int chipWidth: Math.floor((contentWidth - 6) / 2)
  readonly property var playableEffects: (root.room?.effects ?? []).filter(e => e !== "no_effect" && Hue.presetsFor(e).length > 0)

  readonly property var effectLabels: ({
      "no_effect": "Aucun",
      "candle": "Bougie",
      "fire": "Feu",
      "prism": "Prisme",
      "sparkle": "Étincelle",
      "opal": "Opale",
      "glisten": "Éclat",
      "underwater": "Sous l'eau",
      "cosmos": "Cosmos",
      "sunbeam": "Soleil",
      "enchant": "Enchanté"
    })

  readonly property var room: Hue.roomById(root.roomId) ?? (Hue.rooms[0] ?? null)
  readonly property bool anyOn: Hue.rooms.some(r => r.on)

  icon: root.anyOn ? "lightbulb-on" : "lightbulb-outline"
  tooltip: "Lumières"
  checked: root.panelOpen
  onClicked: root.panelOpen = !root.panelOpen

  onPanelOpenChanged: {
    Hue.polling = root.panelOpen;
    if (root.panelOpen)
      Hue.refresh();
    else
      root.expandedLight = "";
  }

  function toggleSection(name: string) {
    root.section = root.section === name ? "" : name;
    root.expandedLight = "";
  }

  function effectLabel(effect: string): string {
    return root.effectLabels[effect] ?? effect;
  }

  function lightIcon(archetype: string): string {
    const a = archetype ?? "";
    if (a.includes("strip"))
      return "led-strip-variant";
    if (a.includes("ceiling"))
      return "ceiling-light";
    if (a.includes("spot"))
      return "track-light";
    if (a.includes("floor") || a.includes("table"))
      return "floor-lamp";
    return "lightbulb";
  }

  Rectangle {
    id: flyout

    parent: root.panelHost ?? root
    visible: root.panelOpen
    z: 10

    // Flies out to the left of the menu it hangs off.
    x: -(width + Theme.gap)
    y: 0

    width: root.panelWidth
    height: body.implicitHeight + 20
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: Theme.radius

    MouseArea {
      anchors.fill: parent
    }

    ColumnLayout {
      id: body

      x: 10
      y: 10
      width: root.contentWidth
      spacing: 8

      RowLayout {
        Layout.fillWidth: true
        spacing: 4

        Text {
          Layout.fillWidth: true
          text: "Lumières"
          color: Theme.fg
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontSize
          font.bold: true
        }

        BarButton {
          icon: "power"
          tooltip: "Tout éteindre"
          tooltipHost: root.tooltipHost
          enabled: root.anyOn
          onClicked: Hue.allOff()
        }
      }

      Text {
        Layout.fillWidth: true
        visible: Hue.loaded && !Hue.available
        text: "Pont Hue injoignable"
        color: Theme.destructive
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
      }

      Text {
        Layout.fillWidth: true
        visible: !Hue.loaded
        text: "Connexion au pont…"
        color: Theme.alpha(Theme.fg, 0.6)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
      }

      Flow {
        Layout.fillWidth: true
        visible: (Hue.rooms?.length ?? 0) > 1
        spacing: 4

        Repeater {
          model: Hue.rooms

          delegate: Chip {
            required property var modelData

            text: modelData.name
            active: root.room?.id === modelData.id
            dim: modelData.on
            onClicked: {
              root.roomId = modelData.id;
              root.expandedLight = "";
            }
          }
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        visible: root.room !== null
        spacing: 8

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 1
          color: Theme.border
        }

        RoomToggle {
          on: root.room?.on ?? false
          label: root.room?.name ?? ""
          onClicked: Hue.setRoomOn(root.room, !root.room.on)
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 4

          SliderIcon {
            icon: "brightness-6"
          }

          HueSlider {
            id: roomDim

            Layout.fillWidth: true
            from: 0
            target: Math.round(root.room?.on ? (root.room?.brightness ?? 0) : 0)
            onCommit: v => Hue.setRoomBrightness(root.room, v)
          }

          ValueLabel {
            Layout.preferredWidth: 34
            text: Math.round(roomDim.value) + "%"
          }
        }

        TemperatureRow {
          visible: root.room?.ct ?? false
          mirek: root.room?.mirek ?? 0
          mirekMin: root.room?.mirekMin ?? 153
          mirekMax: root.room?.mirekMax ?? 500
          onPicked: m => Hue.setRoomMirek(root.room, m)
        }

        ColorRow {
          visible: root.room?.hasColor ?? false
          colorX: root.room?.colorX ?? 0
          colorY: root.room?.colorY ?? 0
          onPicked: h => Hue.setRoomColor(root.room, h)
        }

        ColumnLayout {
          Layout.fillWidth: true
          visible: (root.room?.scenes?.length ?? 0) > 0
          spacing: 6

          SectionHeader {
            text: "Scènes"
            open: root.section === "scenes"
            onClicked: root.toggleSection("scenes")
          }

          Flow {
            Layout.fillWidth: true
            visible: root.section === "scenes"
            spacing: 6

            Repeater {
              model: root.room?.scenes ?? []

              delegate: Chip {
                required property var modelData

                width: root.chipWidth
                text: modelData.name
                active: modelData.active
                showSwatch: true
                swatch: modelData.colors
                onClicked: Hue.recallScene(root.room.id, modelData.id)
              }
            }
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          visible: (root.room?.effects?.length ?? 0) > 1
          spacing: 6

          SectionHeader {
            text: "Effets"
            open: root.section === "effects"
            onClicked: root.toggleSection("effects")
          }

          ColumnLayout {
            Layout.fillWidth: true
            visible: root.section === "effects"
            spacing: 2

            EffectRow {
              label: "Aucun"
              active: root.room?.effect === "no_effect"
              onCleared: Hue.setRoomEffect(root.room, "no_effect")
            }

            Repeater {
              model: root.playableEffects

              delegate: EffectRow {
                required property var modelData

                effect: modelData
                label: root.effectLabel(modelData)
                presets: Hue.presetsFor(modelData)
              }
            }
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 6

          SectionHeader {
            text: "Lampes"
            open: root.section === "lights"
            onClicked: root.toggleSection("lights")
          }

          Repeater {
            model: root.section === "lights" ? (root.room?.lights ?? []) : []

            delegate: ColumnLayout {
              id: lightRow

              required property var modelData

              readonly property bool expanded: root.expandedLight === modelData.id
              readonly property bool tunable: modelData.ct || modelData.hasColor


              Layout.fillWidth: true
              spacing: 4

              RowLayout {
                Layout.fillWidth: true
                spacing: 4

                BarButton {
                  icon: root.lightIcon(lightRow.modelData.archetype)
                  checked: lightRow.modelData.on
                  tooltip: lightRow.modelData.on ? "Éteindre" : "Allumer"
                  tooltipHost: root.tooltipHost
                  implicitWidth: 26
                  implicitHeight: 26
                  onClicked: Hue.setLightOn(lightRow.modelData, !lightRow.modelData.on)
                }

                Text {
                  Layout.fillWidth: true
                  text: lightRow.modelData.name
                  elide: Text.ElideRight
                  opacity: lightRow.modelData.on ? 1 : 0.6
                  color: Theme.fg
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSize
                }

                HueSlider {
                  Layout.preferredWidth: 100
                  from: 0
                  target: Math.round(lightRow.modelData.on ? lightRow.modelData.brightness : 0)
                  onCommit: v => Hue.setLightBrightness(lightRow.modelData, v)
                }

                BarButton {
                  visible: lightRow.tunable
                  icon: lightRow.expanded ? "chevron-up" : "chevron-down"
                  tooltip: lightRow.expanded ? "Masquer les réglages" : "Température et couleur"
                  tooltipHost: root.tooltipHost
                  checked: lightRow.expanded
                  implicitWidth: 22
                  implicitHeight: 22
                  onClicked: root.expandedLight = lightRow.expanded ? "" : lightRow.modelData.id
                }
              }

              TemperatureRow {
                Layout.leftMargin: 30
                visible: lightRow.expanded && lightRow.modelData.ct
                mirek: lightRow.modelData.mirek
                mirekMin: lightRow.modelData.mirekMin
                mirekMax: lightRow.modelData.mirekMax
                onPicked: m => Hue.setLightMirek(lightRow.modelData, m)
              }

              ColorRow {
                Layout.leftMargin: 30
                visible: lightRow.expanded && lightRow.modelData.hasColor
                colorX: lightRow.modelData.colorX
                colorY: lightRow.modelData.colorY
                onPicked: h => Hue.setLightColor(lightRow.modelData, h)
              }
            }
          }
        }
      }
    }
  }

  Gradient {
    id: hueGradient

    orientation: Gradient.Horizontal

    GradientStop { position: 0.000; color: "#ff0000" }
    GradientStop { position: 0.167; color: "#ffff00" }
    GradientStop { position: 0.333; color: "#00ff00" }
    GradientStop { position: 0.500; color: "#00ffff" }
    GradientStop { position: 0.667; color: "#0000ff" }
    GradientStop { position: 0.833; color: "#ff00ff" }
    GradientStop { position: 1.000; color: "#ff0000" }
  }

  component EffectRow: Rectangle {
    id: row

    property string effect: ""
    property alias label: rowLabel.text
    property var presets: []
    property bool active: false

    signal cleared

    Layout.fillWidth: true
    implicitHeight: 30
    radius: Theme.radius
    color: {
      if (row.active)
        return Theme.alpha(Theme.selectedBg, 0.3);
      if (rowHover.containsMouse)
        return Theme.alpha(Theme.fg, 0.1);
      return "transparent";
    }

    // Declared before the content so the dots stay on top of it.
    MouseArea {
      id: rowHover

      anchors.fill: parent
      hoverEnabled: true
      onClicked: {
        if (row.presets.length === 0)
          row.cleared();
        else
          Hue.applyPreset(root.room, row.effect, row.presets[0]);
      }
    }

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 8
      anchors.rightMargin: 6
      spacing: 6

      Text {
        id: rowLabel

        Layout.fillWidth: true
        elide: Text.ElideRight
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
      }

      Repeater {
        model: row.presets

        delegate: Rectangle {
          id: dot

          required property var modelData

          readonly property bool picked: Hue.presetActive(root.room, row.effect, modelData)

          Layout.alignment: Qt.AlignVCenter
          implicitWidth: 18
          implicitHeight: 18
          radius: 9
          color: Hue.presetColor(modelData)
          border.width: dot.picked ? 3 : 1
          border.color: dot.picked ? Theme.fg : Theme.alpha(Theme.fg, 0.3)

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onEntered: dotTip.restart()
            onExited: {
              dotTip.stop();
              if (root.tooltipHost?.target === dot)
                root.tooltipHost.hide();
            }
            onClicked: {
              dotTip.stop();
              if (root.tooltipHost?.target === dot)
                root.tooltipHost.hide();
              Hue.applyPreset(root.room, row.effect, dot.modelData);
            }
          }

          Timer {
            id: dotTip

            interval: 500
            onTriggered: root.tooltipHost?.show(dot, dot.modelData.label)
          }

          Component.onDestruction: if (root.tooltipHost?.target === dot)
            root.tooltipHost.hide()
        }
      }
    }

  }

  component SectionHeader: Rectangle {
    id: header

    property alias text: headerText.text
    property bool open: false

    signal clicked

    Layout.fillWidth: true
    implicitHeight: 26
    radius: Theme.radius
    color: headerHover.containsMouse ? Theme.alpha(Theme.fg, 0.1) : "transparent"

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 4
      anchors.rightMargin: 4
      spacing: 4

      Text {
        id: headerText

        Layout.fillWidth: true
        color: Theme.alpha(Theme.fg, 0.6)
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
      }

      Icon {
        Layout.alignment: Qt.AlignVCenter
        icon: header.open ? "chevron-up" : "chevron-down"
        color: Theme.alpha(Theme.fg, 0.6)
        size: 14
      }
    }

    MouseArea {
      id: headerHover

      anchors.fill: parent
      hoverEnabled: true
      onClicked: header.clicked()
    }
  }

  component ValueLabel: Text {
    Layout.alignment: Qt.AlignVCenter
    Layout.leftMargin: 4
    horizontalAlignment: Text.AlignRight
    color: Theme.fg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
  }

  component TemperatureRow: RowLayout {
    id: tempRow

    property int mirek: 0
    property int mirekMin: 153
    property int mirekMax: 500

    signal picked(int mirek)

    readonly property int kelvin: tempRow.mirek > 0 ? Math.round(1000000 / tempRow.mirek) : 2700

    Layout.fillWidth: true
    spacing: 4

    SliderIcon {
      icon: "thermometer"
    }

    HueSlider {
      id: tempSlider

      Layout.fillWidth: true
      from: Math.round(1000000 / tempRow.mirekMax)
      to: Math.round(1000000 / tempRow.mirekMin)
      stepSize: 50
      target: Math.max(from, Math.min(to, tempRow.kelvin))
      fillColor: Hue.mirekColor(1000000 / Math.max(1, tempSlider.value))
      onCommit: v => tempRow.picked(Math.round(1000000 / v))
    }

    ValueLabel {
      Layout.preferredWidth: 42
      text: Math.round(tempSlider.value / 50) * 50 + "K"
    }
  }

  component ColorRow: RowLayout {
    id: colorRow

    property real colorX: 0
    property real colorY: 0

    signal picked(real hue)

    readonly property real hue: colorRow.colorX > 0 ? Hue.xyColor(colorRow.colorX, colorRow.colorY).hsvHue * 360 : 0

    Layout.fillWidth: true
    spacing: 4

    SliderIcon {
      icon: "palette"
    }

    HueSlider {
      id: hueSlider

      Layout.fillWidth: true
      from: 0
      to: 359
      rainbow: true
      target: colorRow.hue
      onCommit: v => colorRow.picked(v)
    }

    Rectangle {
      Layout.alignment: Qt.AlignVCenter
      Layout.leftMargin: 4
      Layout.preferredWidth: 34
      implicitHeight: 16
      radius: 4
      color: Qt.hsva(hueSlider.value / 360, 1, 1, 1)
    }
  }

  // A label, not a control: the slider next to it is what you touch.
  component SliderIcon: Item {
    property alias icon: glyph.icon

    implicitWidth: 30
    implicitHeight: 30
    Layout.alignment: Qt.AlignVCenter

    Icon {
      id: glyph

      anchors.centerIn: parent
      size: 16
    }
  }

  component RoomToggle: Rectangle {
    id: toggle

    property bool on: false
    property alias label: toggleLabel.text

    signal clicked

    Layout.fillWidth: true
    implicitHeight: 36
    radius: Theme.radius
    color: toggleHover.containsMouse ? Theme.alpha(Theme.fg, 0.14) : Theme.alpha(Theme.fg, 0.07)

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 10
      anchors.rightMargin: 10
      spacing: 8

      Icon {
        Layout.alignment: Qt.AlignVCenter
        icon: toggle.on ? "lightbulb-on" : "lightbulb-outline"
        size: 16
      }

      Text {
        id: toggleLabel

        Layout.fillWidth: true
        elide: Text.ElideRight
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
      }

      Rectangle {
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: 34
        implicitHeight: 18
        radius: 9
        color: toggle.on ? Theme.selectedBg : Theme.alpha(Theme.fg, 0.25)

        Rectangle {
          x: toggle.on ? parent.width - width - 3 : 3
          anchors.verticalCenter: parent.verticalCenter
          implicitWidth: 12
          implicitHeight: 12
          radius: 6
          color: toggle.on ? Theme.selectedFg : Theme.bg

          Behavior on x {
            NumberAnimation {
              duration: 120
              easing.type: Easing.OutCubic
            }
          }
        }
      }
    }

    MouseArea {
      id: toggleHover

      anchors.fill: parent
      hoverEnabled: true
      onClicked: toggle.clicked()
    }
  }

  component HueSlider: Slider {
    id: slider

    // Value coming from the bridge; the handle snaps back to it between edits.
    property real target: 0
    property color fillColor: Theme.selectedBg
    property bool rainbow: false

    signal commit(real value)

    from: 1
    to: 100
    stepSize: 1
    wheelEnabled: true
    implicitHeight: 24
    Layout.alignment: Qt.AlignVCenter

    onMoved: debounce.restart()

    Binding {
      target: slider
      property: "value"
      value: slider.target
      when: !slider.pressed && !debounce.running
      restoreMode: Binding.RestoreNone
    }

    Timer {
      id: debounce

      interval: 120
      onTriggered: slider.commit(slider.value)
    }

    background: Rectangle {
      x: slider.leftPadding
      y: slider.topPadding + slider.availableHeight / 2 - height / 2
      width: slider.availableWidth
      height: slider.rainbow ? 8 : 4
      radius: height / 2
      color: Theme.alpha(Theme.fg, 0.2)

      gradient: slider.rainbow ? hueGradient : null

      Rectangle {
        visible: !slider.rainbow
        width: slider.visualPosition * parent.width
        height: parent.height
        radius: parent.radius
        color: slider.fillColor
      }
    }

    handle: Rectangle {
      x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
      y: slider.topPadding + slider.availableHeight / 2 - height / 2
      implicitWidth: 14
      implicitHeight: 14
      radius: width / 2
      color: slider.pressed ? slider.fillColor : Theme.bg
      border.width: 2
      border.color: slider.fillColor
    }
  }

  component Chip: Rectangle {
    id: chip

    property alias text: chipText.text
    property bool active: false
    property bool dim: false
    property var swatch: []

    // Scene chips keep the swatch column even when a scene yields no colour,
    // so their labels stay on one line.
    property bool showSwatch: false

    signal clicked

    implicitWidth: chipRow.implicitWidth + 16
    implicitHeight: 26
    radius: Theme.radius

    color: {
      if (chip.active)
        return Theme.selectedBg;
      if (chipHover.containsMouse)
        return Theme.alpha(Theme.fg, 0.14);
      return Theme.alpha(Theme.fg, chip.dim ? 0.1 : 0.05);
    }

    RowLayout {
      id: chipRow

      anchors.fill: parent
      anchors.leftMargin: 8
      anchors.rightMargin: 8
      spacing: 6

      Rectangle {
        visible: chip.showSwatch
        opacity: chip.swatch.length > 0 ? 1 : 0
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: 12
        implicitHeight: 12
        radius: 3
        clip: true
        color: "transparent"

        Row {
          anchors.fill: parent

          Repeater {
            model: chip.swatch

            delegate: Rectangle {
              required property var modelData

              width: 12 / Math.max(1, chip.swatch.length)
              height: 12
              color: Hue.swatchColor(modelData)
            }
          }
        }
      }

      Text {
        id: chipText

        Layout.fillWidth: true
        elide: Text.ElideRight
        color: chip.active ? Theme.selectedFg : Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
      }
    }

    MouseArea {
      id: chipHover

      anchors.fill: parent
      hoverEnabled: true
      onClicked: chip.clicked()
    }
  }
}
