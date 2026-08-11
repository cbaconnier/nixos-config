import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import AstalHyprland from "gi://AstalHyprland"
import { createBinding, createComputed, createState, onCleanup } from "ags"
import { kioskWorkspaceIds } from "./BarVisibility"
import Clock from "./Clock"
import Tray from "./Tray"
import { Workspaces } from "./Workspaces"
import Notification from "./Notification"
// import ToggleNotification, { notificationsEnabled } from "./ToggleNotification"
import Menu from "./Menu"
import { keepAwake } from "./KeepAwake"
import MediaPlayer, { isAnyPlayerShown } from "./MediaPlayer"
import Separator from "./Separator"
import Battery from "./Battery"
import {
  microphoneMuted,
  // speakerMuted,
  Microphone,
  // Speaker
} from "./Volume"

const HIDE_DELAY_MS = 1000
const HOVER_ZONE_HEIGHT = 10

function attachHoverMotion(
  self: Gtk.Widget,
  handlers: { onEnter: () => void; onLeave?: () => void },
) {
  const motion = new Gtk.EventControllerMotion()
  motion.connect("enter", handlers.onEnter)
  if (handlers.onLeave) motion.connect("leave", handlers.onLeave)
  self.add_controller(motion)
}

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor
  const connector = gdkmonitor.connector ?? String(Math.random())
  const showMediaSeparator = isAnyPlayerShown()

  // In kiosk mode the main bar window is fully hidden (not just its
  // content), and a tiny separate always-present window catches the hover
  // that brings it back.
  const hyprMonitor = AstalHyprland.get_default().monitors.find(
    (m) => m.name === connector,
  )
  const activeWorkspaceId = hyprMonitor
    ? createBinding(hyprMonitor, "activeWorkspace")((ws) => ws?.id)
    : undefined
  const inKiosk = createComputed(() => {
    const id = activeWorkspaceId?.()
    return id !== undefined && kioskWorkspaceIds().has(id)
  })

  const [hovering, setHovering] = createState(false)
  const revealed = createComputed(() => !inKiosk() || hovering())
  const exclusivity = createComputed(() =>
    inKiosk() ? Astal.Exclusivity.NORMAL : Astal.Exclusivity.EXCLUSIVE,
  )
  const hoverZoneVisible = createComputed(() => inKiosk() && !revealed())

  let hideTimer: ReturnType<typeof setTimeout> | null = null
  const clearHideTimer = () => {
    if (hideTimer !== null) {
      clearTimeout(hideTimer)
      hideTimer = null
    }
  }
  const onEnter = () => {
    clearHideTimer()
    setHovering(true)
  }
  const onLeave = () => {
    clearHideTimer()
    hideTimer = setTimeout(() => setHovering(false), HIDE_DELAY_MS)
  }

  const mainBar = (
    <window
      visible={revealed}
      name={`bar-${connector}`}
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={exclusivity}
      anchor={TOP | LEFT | RIGHT}
      application={app}
      $={(self) => {
        attachHoverMotion(self, { onEnter, onLeave })
        onCleanup(() => {
          clearHideTimer()
          self.destroy()
        })
      }}
    >
      <centerbox cssName="centerbox" hexpand>
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
          <image
            class="keep-awake-indicator"
            iconName="changes-allow-symbolic"
            visible={keepAwake((m) => m)}
          />
          {/* <ToggleNotification */}
          {/*   visible={notificationsEnabled((enabled) => !enabled)} */}
          {/* /> */}
          <Menu
            onOpenChange={(open) => (open ? onEnter() : onLeave())}
          />
        </box>
      </centerbox>
    </window>
  )

  const hoverZone = (
    <window
      visible={hoverZoneVisible}
      name={`bar-hover-${connector}`}
      class="kiosk-hover-zone"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.NORMAL}
      layer={Astal.Layer.OVERLAY}
      anchor={TOP | LEFT | RIGHT}
      application={app}
      $={(self) => {
        attachHoverMotion(self, { onEnter })
        onCleanup(() => self.destroy())
      }}
    >
      <box hexpand heightRequest={HOVER_ZONE_HEIGHT} />
    </window>
  )

  return [mainBar, hoverZone]
}
