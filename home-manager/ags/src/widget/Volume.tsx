import AstalWp from "gi://AstalWp";
import { createBinding } from "ags";
import { Gtk } from "ags/gtk4";

export function Speaker() {
  const { defaultSpeaker: speaker } = AstalWp.get_default()!;

  return (
    <box orientation={Gtk.Orientation.HORIZONTAL}>
      <image iconName={createBinding(speaker, "volumeIcon")} />
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

  return (
    <box orientation={Gtk.Orientation.HORIZONTAL}>
      <image iconName="audio-input-microphone" />
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
