import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import Clock from "./Clock"
import Tray from "./Tray"
import { Workspaces } from "./Workspaces"
import Notification from "./Notification"
import ToggleNotification from "./ToggleNotification"
import Menu from "./Menu"
import MediaPlayer from "./MediaPlayer"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  function Separator() {
    return <box class="separator" valign={Gtk.Align.CENTER} />
  }

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
          <Separator />
          <MediaPlayer />
        </box>

        <box hexpand halign={Gtk.Align.CENTER} $type="center">
          <Notification />
        </box>

        <box $type="end">
          <Clock />
          <Separator />
          <Tray />
          <Separator />
          <ToggleNotification />
          <Menu />
        </box>
      </centerbox>
    </window>
  )
}
