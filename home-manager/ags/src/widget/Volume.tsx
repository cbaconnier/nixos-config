import AstalWp from "gi://AstalWp";
import { createBinding, createState } from "ags";
import { Gtk } from "ags/gtk4";

export function Speaker() {
  const { defaultSpeaker: speaker } = AstalWp.get_default()!;

  return (
    <box orientation={Gtk.Orientation.HORIZONTAL}>
      <button onClicked={() => speaker.set_mute(!speaker.get_mute())}>
        <image iconName={createBinding(speaker, "volumeIcon")} />
      </button>
      <slider
        widthRequest={260}
        onChangeValue={({ value }) => speaker.set_volume(value)}
        value={createBinding(speaker, "volume")}
      />
      <label
        label={createBinding(speaker, "volume").as(
          (volume) => Math.round(volume * 100).toString() + "%",
        )}
      />
    </box>
  );
}

export function Microphone() {
  const { defaultMicrophone: microphone } = AstalWp.get_default()!;

  // https://github.com/Aylur/astal/issues/361
  const getVolumeIcon = () => {
    if (microphone.mute) return "microphone-sensitivity-muted-symbolic";
    if (microphone.volume <= 0.33) return "microphone-sensitivity-low-symbolic";
    if (microphone.volume <= 0.66)
      return "microphone-sensitivity-medium-symbolic";
    return "microphone-sensitivity-high-symbolic";
  };

  const [volumeIcon, setVolumeIcon] = createState<string>(getVolumeIcon());
  microphone.connect("notify::mute", () => setVolumeIcon(getVolumeIcon()));
  microphone.connect("notify::volume", () => setVolumeIcon(getVolumeIcon()));

  return (
    <box orientation={Gtk.Orientation.HORIZONTAL}>
      <button onClicked={() => microphone.set_mute(!microphone.get_mute())}>
        <image iconName={volumeIcon} />
      </button>
      <slider
        widthRequest={260}
        onChangeValue={({ value }) => microphone.set_volume(value)}
        value={createBinding(microphone, "volume")}
      />
      <label
        label={createBinding(microphone, "volume").as(
          (volume) => Math.round(volume * 100).toString() + "%",
        )}
      />
    </box>
  );
}
