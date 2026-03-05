import AstalBattery from "gi://AstalBattery"
import { createBinding, createComputed } from "ags"

export default function Battery() {
  const battery = AstalBattery.get_default()
  if (!battery) return <box visible={false} />

  const isPresent = createBinding(battery, "isPresent")
  const percentage = createBinding(battery, "percentage")
  const visible = createComputed(() => isPresent() && percentage() < 1)

  return (
    <box
      cssClasses={percentage((p) => (p * 100 <= 20 ? ["battery", "low"] : ["battery"]))}
      visible={visible}
    >
      <image iconName={createBinding(battery, "batteryIconName")} />
      <label label={percentage((p) => `${Math.round(p * 100)}%`)} />
    </box>
  )
}
