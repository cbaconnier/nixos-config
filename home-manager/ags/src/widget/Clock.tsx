import { Gtk } from "ags/gtk4";
import { createPoll } from "ags/time";

export default function Clock() {
  const time = createPoll("", 1000, "date '+%H:%M:%S - %e %b.'");

  return (
    <menubutton $type="end" hexpand halign={Gtk.Align.CENTER}>
      <label label={time} />
      <popover>
        <Gtk.Calendar />
      </popover>
    </menubutton>
  );
}
