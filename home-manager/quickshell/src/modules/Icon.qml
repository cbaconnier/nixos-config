import QtQuick
import ".."

Item {
  id: root

  property string icon
  property color color: Theme.fg
  property int size: 16
  // Tabler glyphs are thin outlines on a 24 px grid and read smaller than filled glyphs
  property real glyphScale: 1.125

  implicitWidth: size
  implicitHeight: size

  // Names from https://tabler.io/icons
  readonly property var codepoints: ({
      "bell": 0xea35,
      "bell-off": 0xece9,
      "layout-sidebar-right-collapse": 0xf006,
      "device-desktop-bolt": 0xf85e,
      "sunset-2": 0xf23a,
      "apps": 0xebb6,
      "power": 0xeb0d,
      "chevron-up": 0xea62,
      "chevron-down": 0xea5f,
      "chevron-left": 0xea60,
      "chevron-right": 0xea61,
      "check": 0xea5e,
      "player-skip-back": 0xed48,
      "player-skip-forward": 0xed49,
      "player-play": 0xed46,
      "player-pause": 0xed45,
      "volume": 0xeb51,
      "volume-2": 0xeb4f,
      "volume-4": 0x1019d,
      "volume-off": 0xf1c3,
      "microphone": 0xeaf0,
      "microphone-off": 0xed16,
      "sun-low": 0xf237,
      "sun": 0xeb30,
      "sun-high": 0xf236,
      "dots-vertical": 0xea94,
      "battery-vertical-1": 0xff1c,
      "battery-vertical-2": 0xff1b,
      "battery-vertical-3": 0xff1a,
      "battery-vertical-4": 0xff19,
      "battery-vertical-charging": 0xff17,
      "battery-vertical-exclamation": 0xff15,
      "x": 0xeb55,
      "bulb": 0xea51,
      "bulb-off": 0xea50,
      "lamp": 0xefab,
      "lamp-2": 0xf09e,
      "rainbow": 0xedbc,
      "thermometer": 0xef67,
      "palette": 0xeb01,
      "trash": 0xeb41,
      "headphones": 0xeabd,
      "user": 0xeb4d,
      "book-2": 0xefc5,
      "brain": 0xf59f,
      "dragon": 0x10272,
      "ghost-2": 0xf57c
    })

  Text {
    anchors.centerIn: parent
    text: root.icon && root.codepoints[root.icon] !== undefined ? String.fromCodePoint(root.codepoints[root.icon]) : ""
    color: root.color
    font.family: "tabler-icons"
    font.pixelSize: Math.round(root.size * root.glyphScale)
    renderType: Text.NativeRendering
  }
}
