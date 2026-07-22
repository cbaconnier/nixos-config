import { createState } from "ags"
import { execAsync } from "ags/process"

export const [keepAwake, setKeepAwake] = createState(false)

export const refreshKeepAwake = () =>
  execAsync("systemctl --user is-active hypridle")
    .then((out) => setKeepAwake(out.trim() !== "active"))
    .catch(() => setKeepAwake(true))

export default function ToggleKeepAwake() {
  const toggle = () => {
    const next = !keepAwake.get()
    setKeepAwake(next)
    execAsync(
      next
        ? ["systemctl", "--user", "stop", "hypridle"]
        : [
            "bash",
            "-c",
            "systemctl --user reset-failed hypridle; systemctl --user start hypridle",
          ],
    ).catch(console.error)
  }

  return (
    <button
      onClicked={toggle}
      tooltipText={keepAwake((m) =>
        m ? "Activer la mise en veille" : "Désactiver la mise en veille",
      )}
      class={keepAwake((m) => (m ? "keep-awake-active" : "keep-awake-idle"))}
    >
      <image
        iconName={keepAwake((m) =>
          m ? "changes-allow-symbolic" : "changes-prevent-symbolic",
        )}
      />
    </button>
  )
}
