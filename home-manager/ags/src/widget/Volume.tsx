import AstalWp from "gi://AstalWp"
import { createBinding, createState } from "ags"
import { Gtk } from "ags/gtk4"
import { Accessor } from "ags"

const wp = AstalWp.get_default()!

export const speakerMuted = createBinding(wp.defaultSpeaker, "mute")
export const microphoneMuted = createBinding(wp.defaultMicrophone, "mute")

export function Speaker({
  visible = true,
  showSlider = false,
  hexpand = false,
}: {
  visible?: boolean | Accessor<boolean>
  showSlider?: boolean
  hexpand?: boolean
}) {
  const { defaultSpeaker: speaker } = AstalWp.get_default()!

  if (showSlider) {
    return (
      <box
        orientation={Gtk.Orientation.HORIZONTAL}
        visible={visible}
        hexpand={hexpand}
      >
        <button onClicked={() => speaker.set_mute(!speaker.get_mute())}>
          <image iconName={createBinding(speaker, "volumeIcon")} />
        </button>
        <slider
          hexpand
          widthRequest={200}
          onChangeValue={({ value }) => speaker.set_volume(value)}
          value={createBinding(speaker, "volume")}
        />
        <label
          label={createBinding(speaker, "volume").as(
            (volume) => Math.round(volume * 100).toString() + "%",
          )}
        />
      </box>
    )
  }

  return (
    <button
      class="toggle-speaker"
      onClicked={() => speaker.set_mute(!speaker.get_mute())}
      visible={visible}
    >
      <image iconName={createBinding(speaker, "volumeIcon")} />
    </button>
  )
}

export function Microphone({
  visible = true,
  showSlider = false,
  hexpand = false,
}: {
  visible?: boolean | Accessor<boolean>
  showSlider?: boolean
  hexpand?: boolean
}) {
  const { defaultMicrophone: microphone } = AstalWp.get_default()!

  // https://github.com/Aylur/astal/issues/361
  const getVolumeIcon = () => {
    if (microphone.mute) return "microphone-sensitivity-muted-symbolic"
    if (microphone.volume <= 0.33) return "microphone-sensitivity-low-symbolic"
    if (microphone.volume <= 0.66)
      return "microphone-sensitivity-medium-symbolic"
    return "microphone-sensitivity-high-symbolic"
  }

  const [volumeIcon, setVolumeIcon] = createState<string>(getVolumeIcon())
  microphone.connect("notify::mute", () => setVolumeIcon(getVolumeIcon()))
  microphone.connect("notify::volume", () => setVolumeIcon(getVolumeIcon()))

  if (showSlider) {
    return (
      <box
        orientation={Gtk.Orientation.HORIZONTAL}
        visible={visible}
        hexpand={hexpand}
      >
        <button onClicked={() => microphone.set_mute(!microphone.get_mute())}>
          <image iconName={volumeIcon} />
        </button>
        <slider
          hexpand
          widthRequest={200}
          onChangeValue={({ value }) => microphone.set_volume(value)}
          value={createBinding(microphone, "volume")}
        />
        <label
          label={createBinding(microphone, "volume").as(
            (volume) => Math.round(volume * 100).toString() + "%",
          )}
        />
      </box>
    )
  }

  return (
    <button
      class="toggle-microphone"
      onClicked={() => microphone.set_mute(!microphone.get_mute())}
      visible={visible}
    >
      <image iconName={volumeIcon} />
    </button>
  )
}
