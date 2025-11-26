import { Gtk } from "ags/gtk4"
import { Speaker, Microphone } from "./Volume"
import ToggleNotification from "./ToggleNotification"
import { execAsync } from "ags/process"

export default function Menu() {
  const openPowerMenu = () => {
    execAsync("power-menu").catch(console.error)
  }

  const openAppMenu = () => {
    execAsync("rofi -show drun -modes drun").catch(console.error)
  }

  return (
    <menubutton>
      <image iconName="view-more-symbolic" />
      <popover>
        <box
          orientation={Gtk.Orientation.VERTICAL}
          widthRequest={350}
          spacing={8}
        >
          <Speaker showSlider />
          <Microphone showSlider />

          <box class="menu-separator" />

          <box orientation={Gtk.Orientation.HORIZONTAL} spacing={8} homogeneous>
            <ToggleNotification />

            <button onClicked={openAppMenu}>
              <image iconName="view-app-grid-symbolic" />
            </button>

            <button onClicked={openPowerMenu}>
              <image iconName="system-shutdown-symbolic" />
            </button>
          </box>
        </box>
      </popover>
    </menubutton>
  )
}
