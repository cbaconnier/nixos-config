import app from "ags/gtk4/app";
import { Astal, Gdk, Gtk } from "ags/gtk4";
import Clock from "./Clock";
import Tray from "./Tray";
import Volume from "./Volume";
import { Workspaces } from "./Workspaces";
import Notification from "./Notification";
import Welcome from "./Welcome";

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  return (
    <window
      visible
      name="bar"
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox cssName="centerbox">
        <box $type="start">
          <Workspaces gdkmonitor={gdkmonitor} />
        </box>

        <box hexpand halign={Gtk.Align.CENTER} $type="center">
          <Notification />
        </box>

        <box $type="end">
          <Volume />
          <Clock />
          <Tray />
        </box>
      </centerbox>
    </window>
  );
}
