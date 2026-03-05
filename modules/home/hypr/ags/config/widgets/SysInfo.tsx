import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"
import HoverPopover from "./HoverPopover"

function sh(cmd: string): string[] {
  return ["bash", "-c", cmd]
}

export default function SysInfo() {
  const cpuUsage = createPoll("...", 2500, sh("top -bn1 | grep 'Cpu(s)' | awk '{print $2\"%\"}'"))
  const cpuTemp = createPoll(
    "...",
    2500,
    sh("sensors 2>/dev/null | grep -m1 'Package' | awk '{print $4}' || echo 'N/A'"),
  )
  const ram = createPoll("...", 2500, sh("free -h | awk '/Mem:/{print $3\" / \"$2}'"))
  const storage = createPoll(
    "...",
    30000,
    sh("df -h / | awk 'NR==2{print $3\" / \"$2\" (\"$5\")\"}'"),
  )
  const net = createPoll(
    "...",
    1000,
    sh("ip -brief addr show | grep -e UP -e UNKNOWN | awk '{print $1\": \"$3}' | sed 's|/.*||'"),
  )
  const gpu = createPoll(
    "",
    2500,
    sh("nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null || echo ''"),
  )

  const popoverContent = (
    <box orientation={Gtk.Orientation.VERTICAL} cssClasses={["sysinfo-content"]}>
      <box cssClasses={["sysinfo-section"]}>
        <label label=" CPU" cssClasses={["sysinfo-header"]} halign={Gtk.Align.START} />
      </box>
      <label label={cpuUsage((u) => `  Usage: ${u}`)} halign={Gtk.Align.START} />
      <label label={cpuTemp((t) => `  Temp: ${t}`)} halign={Gtk.Align.START} />

      <box cssClasses={["sysinfo-section"]}>
        <label label=" RAM" cssClasses={["sysinfo-header"]} halign={Gtk.Align.START} />
      </box>
      <label label={ram((r) => `  Used: ${r}`)} halign={Gtk.Align.START} />

      <box cssClasses={["sysinfo-section"]}>
        <label label="󱛟 Storage" cssClasses={["sysinfo-header"]} halign={Gtk.Align.START} />
      </box>
      <label label={storage((s) => `  /: ${s}`)} halign={Gtk.Align.START} />

      <box cssClasses={["sysinfo-section"]}>
        <label label="󰈀 Network" cssClasses={["sysinfo-header"]} halign={Gtk.Align.START} />
      </box>
      <label
        label={net((n) =>
          n
            .split("\n")
            .filter((l) => l.trim())
            .map((l) => `  ${l}`)
            .join("\n"),
        )}
        halign={Gtk.Align.START}
      />

      <box
        orientation={Gtk.Orientation.VERTICAL}
        visible={gpu((g) => g.trim() !== "")}
      >
        <box cssClasses={["sysinfo-section"]}>
          <label label="󰍹 GPU" cssClasses={["sysinfo-header"]} halign={Gtk.Align.START} />
        </box>
        <label
          label={gpu((g) => {
            if (!g.trim()) return ""
            const [util, temp, memUsed, memTotal] = g.split(",").map((s) => s.trim())
            return `  Usage: ${util}%, Temp: ${temp}°C, VRAM: ${memUsed}M / ${memTotal}M`
          })}
          halign={Gtk.Align.START}
        />
      </box>
    </box>
  )

  return (
    <HoverPopover label="info" cssClasses={["sysinfo"]}>
      {popoverContent}
    </HoverPopover>
  )
}
