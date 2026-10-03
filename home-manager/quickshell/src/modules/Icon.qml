import QtQuick
import ".."

Item {
  id: root

  property string icon
  property color color: Theme.fg
  property int size: 16

  implicitWidth: size
  implicitHeight: size

  // References https://pictogrammers.com/library/mdi/
  readonly property var codepoints: ({
      "bell": 0xf009a,
      "bell-off": 0xf009b,
      "coffee": 0xf0176,
      "moon-waning-crescent": 0xf0f65,
      "white-balance-sunny": 0xf05a8,
      "apps": 0xf003b,
      "power": 0xf0425,
      "chevron-up": 0xf0143,
      "chevron-down": 0xf0140,
      "chevron-left": 0xf0141,
      "chevron-right": 0xf0142,
      "check": 0xf012c,
      "skip-previous": 0xf04ae,
      "skip-next": 0xf04ad,
      "play": 0xf040a,
      "pause": 0xf03e4,
      "volume-off": 0xf0581,
      "volume-low": 0xf057f,
      "volume-medium": 0xf0580,
      "volume-high": 0xf057e,
      "microphone": 0xf036c,
      "microphone-off": 0xf036d,
      "brightness-5": 0xf00de,
      "brightness-6": 0xf00df,
      "brightness-7": 0xf00e0,
      "dots-vertical": 0xf01d9,
      "battery": 0xf0079,
      "battery-10": 0xf007a,
      "battery-30": 0xf007c,
      "battery-50": 0xf007e,
      "battery-70": 0xf0080,
      "battery-90": 0xf0082,
      "battery-alert": 0xf0083,
      "battery-charging-20": 0xf0086,
      "battery-charging-30": 0xf0087,
      "battery-charging-40": 0xf0088,
      "battery-charging-80": 0xf008a,
      "battery-charging-90": 0xf008b,
      "battery-charging-100": 0xf0085,
      "close": 0xf0156,
      "lightbulb": 0xf0335,
      "lightbulb-on": 0xf06e8,
      "lightbulb-outline": 0xf0336,
      "ceiling-light": 0xf0769,
      "track-light": 0xf0914,
      "floor-lamp": 0xf08dd,
      "led-strip-variant": 0xf1051,
      "thermometer": 0xf050f,
      "palette": 0xf03d8,
      "broom": 0xf00e2
    })

  Text {
    anchors.centerIn: parent
    text: root.icon && root.codepoints[root.icon] !== undefined ? String.fromCodePoint(root.codepoints[root.icon]) : ""
    color: root.color
    font.family: "Material Design Icons"
    font.pixelSize: root.size
    renderType: Text.NativeRendering
  }
}
