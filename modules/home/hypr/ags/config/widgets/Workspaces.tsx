import AstalHyprland from "gi://AstalHyprland"
import { createBinding, For } from "ags"
import { Gtk } from "ags/gtk4"

export default function Workspaces() {
  const hyprland = AstalHyprland.get_default()

  const workspaces = createBinding(hyprland, "workspaces")

  return (
    <box cssClasses={["workspaces"]}>
      <For each={workspaces((ws) =>
        ws
          .filter((w) => !(w.id >= -99 && w.id <= -2))
          .sort((a, b) => a.id - b.id),
      )}>
        {(ws) => (
          <button
            cssClasses={createBinding(hyprland, "focusedWorkspace")((fw) =>
              fw.id === ws.id ? ["workspace-dot", "active"] : ["workspace-dot"],
            )}
            onClicked={() => ws.focus()}
          >
            <label
              label={String(ws.id)}
              halign={Gtk.Align.CENTER}
              valign={Gtk.Align.CENTER}
              xalign={0.5}
            />
          </button>
        )}
      </For>
    </box>
  )
}
