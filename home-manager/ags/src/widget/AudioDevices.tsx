import AstalWp from "gi://AstalWp"
import GLib from "gi://GLib"
import { Accessor, createBinding, createState, For } from "ags"
import { Gtk } from "ags/gtk4"
import { readFile } from "ags/file"

type DeviceRules = { ignore: string[]; rename: Record<string, string> }
type AudioConfig = { speakers: DeviceRules; microphones: DeviceRules }

const emptyRules: DeviceRules = { ignore: [], rename: {} }

function loadConfig(): AudioConfig {
  try {
    const raw = readFile(`${GLib.get_user_config_dir()}/ags-audio.json`)
    const parsed = JSON.parse(raw) as Partial<AudioConfig>
    return {
      speakers: { ...emptyRules, ...parsed.speakers },
      microphones: { ...emptyRules, ...parsed.microphones },
    }
  } catch {
    return { speakers: emptyRules, microphones: emptyRules }
  }
}

const config = loadConfig()

const nodeName = (ep: AstalWp.Endpoint) => ep.get_pw_property("node.name") ?? ""

function labelFor(rules: DeviceRules, ep: AstalWp.Endpoint) {
  return rules.rename[nodeName(ep)] ?? ep.description ?? nodeName(ep) ?? ""
}

function DeviceRow({
  label,
  active,
  onSelect,
}: {
  label: string
  active: Accessor<boolean>
  onSelect: () => void
}) {
  return (
    <button
      class={active.as((a) => (a ? "audio-device active" : "audio-device"))}
      onClicked={onSelect}
    >
      <box spacing={8}>
        <image
          iconName="object-select-symbolic"
          opacity={active.as((a) => (a ? 1 : 0))}
        />
        <label label={label} halign={Gtk.Align.START} hexpand />
      </box>
    </button>
  )
}

export function DevicePicker({ kind }: { kind: "speakers" | "microphones" }) {
  const { audio } = AstalWp.get_default()!
  const rules = config[kind]

  const devices = createBinding(audio, kind).as((list) =>
    list.filter((ep) => !rules.ignore.includes(nodeName(ep))),
  )

  // AstalWp doesn't notify default changes, so track the selection ourselves:
  // seed it from the current default, then update it on click.
  const [selected, setSelected] = createState<number>(-1)
  let seeded = false
  const seed = () => {
    if (seeded) return
    const d = devices.peek().find((ep) => ep.isDefault)
    if (d) {
      setSelected(d.serial)
      seeded = true
    }
  }
  devices.subscribe(seed)
  seed()

  return (
    <menubutton
      class="audio-picker"
      tooltipText={
        kind === "speakers" ? "Changer de haut-parleur" : "Changer de microphone"
      }
    >
      <image iconName="pan-down-symbolic" />
      <popover>
        <box
          orientation={Gtk.Orientation.VERTICAL}
          spacing={2}
          widthRequest={200}
        >
          <For each={devices}>
            {(ep) => (
              <DeviceRow
                label={labelFor(rules, ep)}
                active={selected.as((s) => s === ep.serial)}
                onSelect={() => {
                  ep.set_is_default(true)
                  setSelected(ep.serial)
                  seeded = true
                }}
              />
            )}
          </For>
        </box>
      </popover>
    </menubutton>
  )
}
