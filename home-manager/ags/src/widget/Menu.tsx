import { Gtk } from "ags/gtk4";
import { Microphone, Speaker } from "./Volume";

export default function Menu() {
  return (
    <menubutton>
      <image iconName="view-more-symbolic" />
      <popover>
        <box orientation={Gtk.Orientation.VERTICAL} widthRequest={300}>
          <Speaker />
          <Microphone />
        </box>
      </popover>
    </menubutton>
  );
}
