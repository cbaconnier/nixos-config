pragma Singleton

import QtQuick
import Quickshell
import "."

Singleton {
  readonly property QtObject colors: Palette {}

  readonly property color bg: colors.bg
  readonly property color fg: colors.fg
  readonly property color border: colors.border
  readonly property color selectedBg: colors.selectedBg
  readonly property color selectedFg: colors.selectedFg
  readonly property color text: colors.text
  readonly property color destructive: colors.destructive

  readonly property int barHeight: 40
  readonly property int hoverZoneHeight: 10
  readonly property int hideDelayMs: 1000
  readonly property int radius: 4
  readonly property int itemSpacing: 4
  readonly property int gap: 8

  readonly property string fontFamily: "sans-serif"
  readonly property int fontSize: 13

  function alpha(c: color, a: real): color {
    return Qt.rgba(c.r, c.g, c.b, a);
  }
}
