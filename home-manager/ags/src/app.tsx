import app from "ags/gtk4/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import { setKioskWorkspace } from "./widget/BarVisibility"
import { For, This, createBinding, createComputed, createState } from "ags"

const [barGeneration, setBarGeneration] = createState(0)

app.start({
  css: style,
  requestHandler(argv, res) {
    if (argv[0] === "recreate-bars") {
      setBarGeneration((g) => g + 1)
      return res("ok")
    }
    if (argv[0] === "set-kiosk") {
      const id = Number(argv[1])
      if (!Number.isFinite(id))
        return res("set-kiosk: expected a workspace id")
      setKioskWorkspace(id, argv[2] === "true")
      return res("ok")
    }
    res("unknown request")
  },
  main() {
    const monitors = createBinding(app, "monitors")
    // fresh wrappers each generation so <For> remounts every Bar
    const bars = createComputed(() => {
      barGeneration()
      return monitors().map((monitor) => ({ monitor }))
    })

    return (
      <For each={bars}>
        {({ monitor }) => <This this={app}>{Bar(monitor)}</This>}
      </For>
    )
  },
})
