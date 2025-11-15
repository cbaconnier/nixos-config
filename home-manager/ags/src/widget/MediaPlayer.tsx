import AstalMpris from "gi://AstalMpris"
import { createBinding, For } from "ags"
import { Gtk } from "ags/gtk4"

export default function MediaPlayer() {
  const mpris = AstalMpris.get_default()
  const players = createBinding(mpris, "players")

  return (
    <box class="media-player" spacing={8}>
      <For each={players}>
        {(player) => {
          const isPreferred = players((list) => {
            const preferred =
              list.find(
                (p) => p.playbackStatus === AstalMpris.PlaybackStatus.PLAYING,
              ) || list[0]

            return preferred?.busName === player.busName
          })

          const title = createBinding(player, "title")
          const artist = createBinding(player, "artist")
          const playbackStatus = createBinding(player, "playbackStatus")
          const canGoPrevious = createBinding(player, "canGoPrevious")
          const canGoNext = createBinding(player, "canGoNext")
          const canControl = createBinding(player, "canControl")

          return (
            <box spacing={8} visible={isPreferred}>
              <box>
                <button
                  onClicked={() => player.previous()}
                  sensitive={canGoPrevious}
                >
                  <image iconName="media-skip-backward-symbolic" />
                </button>

                <button
                  onClicked={() => player.play_pause()}
                  sensitive={canControl}
                >
                  <image
                    iconName={playbackStatus((s) =>
                      s === AstalMpris.PlaybackStatus.PLAYING
                        ? "media-playback-pause-symbolic"
                        : "media-playback-start-symbolic",
                    )}
                  />
                </button>

                <button onClicked={() => player.next()} sensitive={canGoNext}>
                  <image iconName="media-skip-forward-symbolic" />
                </button>
              </box>

              <box overflow={Gtk.Overflow.HIDDEN} css="border-radius: 8px;">
                <image
                  iconSize={Gtk.IconSize.LARGE}
                  file={createBinding(player, "coverArt")}
                  name="image"
                />
              </box>

              <box
                orientation={Gtk.Orientation.VERTICAL}
                valign={Gtk.Align.CENTER}
              >
                <label
                  class="media-title"
                  label={title((t) => t || "Unknown Title")}
                  ellipsize={3}
                  maxWidthChars={30}
                  halign={Gtk.Align.START}
                />
                <label
                  class="media-artist"
                  label={artist((a) => a || "Unknown Artist")}
                  ellipsize={3}
                  maxWidthChars={30}
                  halign={Gtk.Align.START}
                />
              </box>
            </box>
          )
        }}
      </For>
    </box>
  )
}
