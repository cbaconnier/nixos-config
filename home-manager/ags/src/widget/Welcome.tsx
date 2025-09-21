import { Gtk } from "ags/gtk4";
import { execAsync } from "ags/process";

export default function Welcome() {
  return (
    <button
      $type="start"
      onClicked={() => execAsync("echo hello").then(console.log)}
      hexpand
      halign={Gtk.Align.CENTER}
    >
      <label label="Welcome to AGS!" />
    </button>
  );
}
