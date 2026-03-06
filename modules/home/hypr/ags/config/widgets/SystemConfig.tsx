import AstalWp from "gi://AstalWp"
import AstalBluetooth from "gi://AstalBluetooth"
import AstalNotifd from "gi://AstalNotifd"
import GLib from "gi://GLib"
import { Gtk } from "ags/gtk4"
import { createBinding, createComputed } from "ags"
import { createPoll } from "ags/time"
import HoverPopover from "./HoverPopover"

function sh(cmd: string): string[] {
  return ["bash", "-c", cmd]
}

function VolumeSection() {
  const wp = AstalWp.get_default()
  if (!wp) return <box />
  const speaker = wp.defaultSpeaker
  if (!speaker) return <box />

  const vol = createBinding(speaker, "volume")
  const mute = createBinding(speaker, "mute")

  const scale = new Gtk.Scale({
    orientation: Gtk.Orientation.HORIZONTAL,
    cssClasses: ["sysconfig-slider"],
    drawValue: false,
    hexpand: true,
  })
  const adj = scale.get_adjustment()
  adj.set_lower(0)
  adj.set_upper(1)
  adj.set_value(speaker.volume)

  speaker.connect("notify::volume", () => {
    adj.set_value(speaker.volume)
  })

  scale.connect("change-value", (_self: Gtk.Scale, _scroll: Gtk.ScrollType, value: number) => {
    speaker.volume = Math.max(0, Math.min(value, 1))
    return false
  })

  return (
    <box cssClasses={["sysconfig-section"]} spacing={8}>
      <button
        cssClasses={mute((m) => m ? ["sysconfig-toggle", "active"] : ["sysconfig-toggle"])}
        onClicked={() => { speaker.mute = !speaker.mute }}
      >
        <image iconName={mute((m) => m ? "audio-volume-muted-symbolic" : "audio-volume-high-symbolic")} />
      </button>
      {scale}
    </box>
  )
}

function MicSection() {
  const wp = AstalWp.get_default()
  if (!wp) return <box />
  const mic = wp.defaultMicrophone
  if (!mic) return <box />

  const mute = createBinding(mic, "mute")
  const micPeak = createPoll(
    0,
    500,
    sh("pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\\d+%' | head -1 | tr -d '%'"),
    (out) => {
      const val = parseInt(out.trim())
      return isNaN(val) ? 0 : val
    },
  )

  const scale = new Gtk.Scale({
    orientation: Gtk.Orientation.HORIZONTAL,
    cssClasses: ["sysconfig-slider"],
    drawValue: false,
    hexpand: true,
  })
  const adj = scale.get_adjustment()
  adj.set_lower(0)
  adj.set_upper(1)
  adj.set_value(mic.volume)

  mic.connect("notify::volume", () => {
    adj.set_value(mic.volume)
  })

  scale.connect("change-value", (_self: Gtk.Scale, _scroll: Gtk.ScrollType, value: number) => {
    mic.volume = Math.max(0, Math.min(value, 1))
    return false
  })

  return (
    <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
      <box cssClasses={["sysconfig-section"]} spacing={8}>
        <button
          cssClasses={mute((m) => m ? ["sysconfig-toggle", "active"] : ["sysconfig-toggle"])}
          onClicked={() => { mic.mute = !mic.mute }}
        >
          <image iconName={mute((m) => m ? "microphone-disabled-symbolic" : "microphone-sensitivity-high-symbolic")} />
        </button>
        {scale}
      </box>
      <box cssClasses={["mic-peak"]}>
        <box
          cssClasses={["mic-peak-fill"]}
          hexpand={false}
          widthRequest={micPeak((p) => Math.round(p * 2.5))}
        />
      </box>
    </box>
  )
}

function BrightnessSection() {
  const brightness = createPoll(
    "0",
    2000,
    sh("brightnessctl -m | cut -d, -f4 | tr -d '%'"),
  )

  const nightMode = createPoll(
    false,
    3000,
    sh("pgrep -x hyprsunset >/dev/null && echo 1 || echo 0"),
    (out) => out.trim() === "1",
  )

  const scale = new Gtk.Scale({
    orientation: Gtk.Orientation.HORIZONTAL,
    cssClasses: ["sysconfig-slider"],
    drawValue: false,
    hexpand: true,
  })
  const adj = scale.get_adjustment()
  adj.set_lower(1)
  adj.set_upper(100)
  adj.set_value(parseInt(brightness() || "50"))

  let updatingFromPoll = false
  brightness.subscribe((val) => {
    const n = parseInt(val)
    if (!isNaN(n)) {
      updatingFromPoll = true
      adj.set_value(n)
      updatingFromPoll = false
    }
  })

  scale.connect("change-value", (_self: Gtk.Scale, _scroll: Gtk.ScrollType, value: number) => {
    if (!updatingFromPoll) {
      const pct = Math.round(Math.max(1, Math.min(value, 100)))
      GLib.spawn_command_line_async(`brightnessctl set ${pct}%`)
    }
    return false
  })

  return (
    <box cssClasses={["sysconfig-section"]} spacing={8}>
      <image iconName="display-brightness-symbolic" />
      {scale}
      <label label={brightness((b) => `${b}%`)} cssClasses={["sysconfig-value"]} />
      <button
        cssClasses={nightMode((n) => n ? ["night-mode-toggle", "active"] : ["night-mode-toggle"])}
        onClicked={() => {
          GLib.spawn_command_line_async(
            "bash -c 'pgrep -x hyprsunset >/dev/null && pkill hyprsunset || hyprsunset -t 4000'"
          )
        }}
        tooltipText="Night Mode"
      >
        <image iconName="weather-clear-night-symbolic" />
      </button>
    </box>
  )
}

function BluetoothSection() {
  const bt = AstalBluetooth.get_default()
  const powered = createBinding(bt, "isPowered")
  const devices = createBinding(bt, "devices")

  const connectedCount = createComputed(() => {
    const devs = devices()
    return devs.filter((d) => d.connected).length
  })

  return (
    <box cssClasses={["sysconfig-section"]} spacing={8}>
      <image iconName="bluetooth-symbolic" />
      <label label="Bluetooth" hexpand halign={Gtk.Align.START} />
      <label label={connectedCount((c) => c > 0 ? `(${c})` : "")} />
      <Gtk.Switch
        active={powered}
        onStateFlagsChanged={(self: Gtk.Switch) => {
          const adapter = bt.adapter
          if (adapter) adapter.powered = self.active
        }}
      />
    </box>
  )
}

function DndSection() {
  const notifd = AstalNotifd.get_default()
  const dnd = createBinding(notifd, "dontDisturb")

  return (
    <box cssClasses={["sysconfig-section"]} spacing={8}>
      <image iconName="notifications-disabled-symbolic" />
      <label label="Do Not Disturb" hexpand halign={Gtk.Align.START} />
      <Gtk.Switch
        active={dnd}
        onStateFlagsChanged={(self: Gtk.Switch) => {
          notifd.dontDisturb = self.active
        }}
      />
    </box>
  )
}

function TriggerLabel() {
  const wp = AstalWp.get_default()
  const bt = AstalBluetooth.get_default()
  const notifd = AstalNotifd.get_default()

  const modes = ["volume", "mic", "brightness", "bluetooth", "dnd"] as const
  let modeIdx = 0

  const lbl = new Gtk.Label({ cssClasses: ["sysconfig-label"] })

  function update() {
    const mode = modes[modeIdx]
    switch (mode) {
      case "volume": {
        const speaker = wp?.defaultSpeaker
        if (speaker) {
          lbl.label = speaker.mute ? "Vol: Muted" : `Vol: ${Math.round(speaker.volume * 100)}%`
        } else {
          lbl.label = "Vol: N/A"
        }
        break
      }
      case "mic": {
        const mic = wp?.defaultMicrophone
        if (mic) {
          lbl.label = mic.mute ? "Mic: Muted" : `Mic: ${Math.round(mic.volume * 100)}%`
        } else {
          lbl.label = "Mic: N/A"
        }
        break
      }
      case "brightness":
        lbl.label = "Bright"
        break
      case "bluetooth": {
        const powered = bt.isPowered
        const count = bt.devices.filter((d) => d.connected).length
        lbl.label = powered ? `BT: On (${count})` : "BT: Off"
        break
      }
      case "dnd":
        lbl.label = notifd.dontDisturb ? "DND: On" : "DND: Off"
        break
    }
  }

  update()

  // Update periodically
  setInterval(update, 2000)

  const gesture = new Gtk.GestureClick()
  gesture.connect("released", () => {
    modeIdx = (modeIdx + 1) % modes.length
    update()
  })

  const box = new Gtk.Box()
  box.append(lbl)
  box.add_controller(gesture)

  return box
}

export default function SystemConfig() {
  const panel = (
    <box
      orientation={Gtk.Orientation.VERTICAL}
      cssClasses={["sysconfig-panel"]}
      spacing={8}
    >
      <VolumeSection />
      <MicSection />
      <BrightnessSection />
      <BluetoothSection />
      <DndSection />
    </box>
  )

  return (
    <HoverPopover
      trigger={TriggerLabel()}
      cssClasses={["sysconfig"]}
    >
      {panel}
    </HoverPopover>
  )
}
