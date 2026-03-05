import AstalNetwork from "gi://AstalNetwork"
import GLib from "gi://GLib"
import { createBinding, With } from "ags"
import { createPoll } from "ags/time"

export default function Wifi() {
  const network = AstalNetwork.get_default()
  const vpnStatus = createPoll(
    "inactive",
    1000,
    ["bash", "-c", "systemctl is-active wireguard-wg0 2>/dev/null || echo inactive"],
  )
  const wifi = createBinding(network, "wifi")

  return (
    <button
      cssClasses={["wifi"]}
      onClicked={() => GLib.spawn_command_line_async("foot nmtui")}
    >
      <box>
        <box visible={vpnStatus((s) => s.trim() === "active")}>
          <image iconName="network-vpn-symbolic" />
          <label label="VPN" />
        </box>
        <box visible={vpnStatus((s) => s.trim() !== "active")}>
          <With value={wifi}>
            {(w) => {
              if (!w) return <label label="No WiFi" />
              return (
                <box>
                  <image iconName={createBinding(w, "iconName")((icon) => icon ?? "network-wireless-symbolic")} />
                  <label
                    label={createBinding(w, "ssid")((ssid) => ssid || "Disconnected")}
                  />
                </box>
              )
            }}
          </With>
        </box>
      </box>
    </button>
  )
}
