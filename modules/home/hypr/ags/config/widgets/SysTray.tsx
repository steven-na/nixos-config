import AstalTray from "gi://AstalTray"
import { createBinding, For } from "ags"
import HoverPopover from "./HoverPopover"

export default function SysTray() {
  const tray = AstalTray.get_default()

  const trayItems = (
    <box cssClasses={["tray-items"]}>
      <For each={createBinding(tray, "items")}>
        {(item) => (
          <menubutton
            cssClasses={["tray-item"]}
            tooltipText={createBinding(item, "tooltipMarkup")}
            menuModel={createBinding(item, "menuModel")}
          >
            <image gicon={createBinding(item, "gicon")} />
          </menubutton>
        )}
      </For>
    </box>
  )

  return (
    <HoverPopover iconName="pan-down-symbolic" cssClasses={["systray"]}>
      {trayItems}
    </HoverPopover>
  )
}
