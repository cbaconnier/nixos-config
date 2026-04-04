import app from "ags/gtk4/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import { For, This, createBinding } from "ags"

app.start({
  css: style,
  main() {
    const monitors = createBinding(app, "monitors")

    return (
      <For each={monitors}>
        {(monitor) => <This this={app}>{Bar(monitor)}</This>}
      </For>
    )
  },
})
