import AstalHyprland from "gi://AstalHyprland"
import Pango from "gi://Pango"
import { createBinding } from "ags"

export default function WindowTitle() {
  const hyprland = AstalHyprland.get_default()

  return (
    <box cssClasses={["window-title"]}>
      <label
        label={createBinding(hyprland, "focusedClient")((client) =>
          client ? client.title : "",
        )}
        ellipsize={Pango.EllipsizeMode.END}
        maxWidthChars={40}
      />
    </box>
  )
}
