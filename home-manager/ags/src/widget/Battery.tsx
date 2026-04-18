import AstalBattery from "gi://AstalBattery"
import { createBinding, Accessor } from "ags"
import { Gtk } from "ags/gtk4"

const { State } = AstalBattery

function formatTime(seconds: number): string {
  if (seconds <= 0) return ""
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  if (h > 0) return `${h}h${m.toString().padStart(2, "0")}m`
  return `${m}m`
}

function getStateName(state: AstalBattery.State): string {
  switch (state) {
    case State.CHARGING:
      return "Charge"
    case State.DISCHARGING:
      return "Décharge"
    case State.EMPTY:
      return "Vide"
    case State.FULLY_CHARGED:
      return "Pleine"
    case State.PENDING_CHARGE:
      return "En attente"
    case State.PENDING_DISCHARGE:
      return "En attente"
    default:
      return "Inconnu"
  }
}

function Row({
  label,
  value,
}: {
  label: string
  value: string | Accessor<string>
}) {
  return (
    <box orientation={Gtk.Orientation.HORIZONTAL} spacing={16}>
      <label label={label} halign={Gtk.Align.START} hexpand />
      <label label={value} halign={Gtk.Align.END} />
    </box>
  )
}

export default function Battery() {
  const battery = AstalBattery.get_default()

  if (!battery.is_battery || !battery.is_present) return <></>

  const state = createBinding(battery, "state")
  const isFull = state.as(
    (s) => s === State.FULLY_CHARGED || s === State.PENDING_CHARGE,
  )

  const pct = createBinding(battery, "percentage").as(
    (p) => `${Math.round(p * 100)}%`,
  )
  const stateName = state.as(getStateName)

  const showAutonomy = state.as((s) => s === State.DISCHARGING)
  const showTimeFull = state.as((s) => s === State.CHARGING)

  const autonomy = createBinding(battery, "timeToEmpty").as(formatTime)
  const timeFull = createBinding(battery, "timeToFull").as(formatTime)
  const consumption = createBinding(battery, "energyRate").as(
    (r) => `${r.toFixed(1)} W`,
  )
  const hasConsumption = createBinding(battery, "energyRate").as((r) => r > 0)

  return (
    <menubutton class="battery">
      <box spacing={4}>
        <image iconName={createBinding(battery, "batteryIconName")} />
        <label label={pct} visible={isFull.as((f) => !f)} />
      </box>
      <popover>
        <box
          orientation={Gtk.Orientation.VERTICAL}
          spacing={4}
          marginTop={8}
          marginBottom={8}
          marginStart={12}
          marginEnd={12}
          widthRequest={225}
        >
          <Row label="État" value={stateName} />
          <Row label="Batterie" value={pct} />
          <box
            visible={showAutonomy}
            orientation={Gtk.Orientation.HORIZONTAL}
            spacing={16}
          >
            <label label="Autonomie" halign={Gtk.Align.START} hexpand />
            <label label={autonomy} halign={Gtk.Align.END} />
          </box>
          <box
            visible={showTimeFull}
            orientation={Gtk.Orientation.HORIZONTAL}
            spacing={16}
          >
            <label label="Charge complète" halign={Gtk.Align.START} hexpand />
            <label label={timeFull} halign={Gtk.Align.END} />
          </box>
          <box
            visible={hasConsumption}
            orientation={Gtk.Orientation.HORIZONTAL}
            spacing={16}
          >
            <label label="Consommation" halign={Gtk.Align.START} hexpand />
            <label label={consumption} halign={Gtk.Align.END} />
          </box>
        </box>
      </popover>
    </menubutton>
  )
}
