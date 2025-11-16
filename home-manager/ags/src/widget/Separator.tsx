import { Gtk } from "ags/gtk4"
import { Accessor } from "ags"

export default function Separator({
  visible = true,
}: {
  visible?: boolean | Accessor<boolean>
}) {
  return <box class="separator" valign={Gtk.Align.CENTER} visible={visible} />
}
