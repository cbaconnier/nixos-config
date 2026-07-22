import { Gtk } from "ags/gtk4"
import { Speaker, Microphone } from "./Volume"
import { DevicePicker } from "./AudioDevices"
import ToggleNotification from "./ToggleNotification"
import ToggleKeepAwake, { refreshKeepAwake } from "./KeepAwake"
import { execAsync } from "ags/process"

export default function Menu() {
  const openPowerMenu = () => {
    execAsync("power-menu").catch(console.error)
  }

  const openAppMenu = () => {
    execAsync("rofi -show drun -modes drun").catch(console.error)
  }

  return (
    <menubutton tooltipText="Menu">
      <image iconName="view-more-symbolic" />
      <popover onShow={refreshKeepAwake}>
        <box
          orientation={Gtk.Orientation.VERTICAL}
          widthRequest={350}
          spacing={8}
        >
          <box spacing={4}>
            <Speaker showSlider hexpand />
            <DevicePicker kind="speakers" />
          </box>
          <box spacing={4}>
            <Microphone showSlider hexpand />
            <DevicePicker kind="microphones" />
          </box>

          <box class="menu-separator" />

          <box orientation={Gtk.Orientation.HORIZONTAL} spacing={8} homogeneous>
            <ToggleNotification />
            <ToggleKeepAwake />

            <button onClicked={openAppMenu} tooltipText="Applications">
              <image iconName="view-app-grid-symbolic" />
            </button>

            <button onClicked={openPowerMenu} tooltipText="Alimentation">
              <image iconName="system-shutdown-symbolic" />
            </button>
          </box>
        </box>
      </popover>
    </menubutton>
  )
}
