import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import { onCleanup } from "ags"
import Clock from "./Clock"
import Tray from "./Tray"
import { Workspaces } from "./Workspaces"
import Notification from "./Notification"
// import ToggleNotification, { notificationsEnabled } from "./ToggleNotification"
import Menu from "./Menu"
import MediaPlayer, { isAnyPlayerShown } from "./MediaPlayer"
import Separator from "./Separator"
import Battery from "./Battery"
import {
  microphoneMuted,
  // speakerMuted,
  Microphone,
  // Speaker
} from "./Volume"

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor
  const connector = gdkmonitor.get_connector() ?? String(Math.random())
  const showMediaSeparator = isAnyPlayerShown()

  return (
    <window
      visible
      name={`bar-${connector}`}
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
      $={(self) => onCleanup(() => self.destroy())}
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
          <Battery />
          <Clock />
          <Separator />
          <Tray />
          {/* <Speaker visible={speakerMuted} /> */}
          <Microphone visible={microphoneMuted((muted) => !muted)} />
          {/* <ToggleNotification */}
          {/*   visible={notificationsEnabled((enabled) => !enabled)} */}
          {/* /> */}
          <Menu />
        </box>
      </centerbox>
    </window>
  )
}
