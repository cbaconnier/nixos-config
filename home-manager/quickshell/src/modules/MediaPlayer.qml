import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import ".."

RowLayout {
  id: root

  property Item tooltipHost: null

  readonly property var allowedApps: ["deezer", "spotify", "mpv", "vlc", "rhythmbox"]

  readonly property var candidates: [...Mpris.players.values].filter(p => root.allowedApps.some(app => p.dbusName.toLowerCase().includes(app)))

  readonly property MprisPlayer player: candidates.find(p => p.playbackState === MprisPlaybackState.Playing) ?? candidates[0] ?? null

  readonly property bool active: player !== null

  visible: active
  spacing: 8
  Layout.alignment: Qt.AlignVCenter

  RowLayout {
    spacing: 0

    BarButton {
      icon: "media-skip-backward-symbolic"
      tooltip: "Précédent"
      tooltipHost: root.tooltipHost
      enabled: root.player?.canGoPrevious ?? false
      onClicked: root.player.previous()
    }

    BarButton {
      icon: root.player?.playbackState === MprisPlaybackState.Playing ? "media-playback-pause-symbolic" : "media-playback-start-symbolic"
      tooltip: root.player?.playbackState === MprisPlaybackState.Playing ? "Pause" : "Lecture"
      tooltipHost: root.tooltipHost
      enabled: root.player?.canControl ?? false
      onClicked: root.player.togglePlaying()
    }

    BarButton {
      icon: "media-skip-forward-symbolic"
      tooltip: "Suivant"
      tooltipHost: root.tooltipHost
      enabled: root.player?.canGoNext ?? false
      onClicked: root.player.next()
    }
  }

  Rectangle {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: 24
    implicitHeight: 24
    radius: 8
    color: "transparent"
    clip: true
    visible: cover.status === Image.Ready

    Image {
      id: cover
      anchors.fill: parent
      source: root.player?.trackArtUrl ?? ""
      fillMode: Image.PreserveAspectCrop
      smooth: true
    }
  }

  ColumnLayout {
    Layout.alignment: Qt.AlignVCenter
    spacing: 0

    Text {
      Layout.maximumWidth: 220
      text: root.player?.trackTitle || "Unknown Title"
      elide: Text.ElideRight
      color: Theme.fg
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize * 0.8
      font.bold: true
    }

    Text {
      Layout.maximumWidth: 220
      text: root.player?.trackArtist || "Unknown Artist"
      elide: Text.ElideRight
      color: Theme.fg
      opacity: 0.8
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontSize * 0.7
    }
  }
}
