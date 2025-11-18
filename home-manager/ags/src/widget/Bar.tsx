import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import Clock from "./Clock"
import Tray from "./Tray"
import { Workspaces } from "./Workspaces"
import Notification from "./Notification"
import ToggleNotification from "./ToggleNotification"
import Menu from "./Menu"
import MediaPlayer, { isAnyPlayerShown } from "./MediaPlayer"
import Separator from "./Separator"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  const showMediaSeparator = isAnyPlayerShown()

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
          <Separator visible={showMediaSeparator} />
          <MediaPlayer />
        </box>

        <box hexpand halign={Gtk.Align.CENTER} $type="center">
          <Notification />
        </box>

        <box hexpand halign={Gtk.Align.END} $type="end">
          <Clock />
          <Separator />
          <Tray />
          <ToggleNotification />
          <Menu />
        </box>
      </centerbox>
    </window>
  )
}
