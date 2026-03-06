import app from "ags/gtk4/app"
import style from "./style.scss"
import { Astal, Gtk } from "ags/gtk4"
import Workspaces from "./widgets/Workspaces"
import WindowTitle from "./widgets/WindowTitle"
import Clock from "./widgets/Clock"
import Battery from "./widgets/Battery"
import Wifi from "./widgets/Wifi"
import SysTray from "./widgets/SysTray"
import SysInfo from "./widgets/SysInfo"
import MusicPlayer from "./widgets/MusicPlayer"
import SystemConfig from "./widgets/SystemConfig"
import { Launcher, setBarRef, openAppLauncher, openPicker, openImagePicker } from "./widgets/Launcher"

app.start({
  css: style,
  main() {
    app.apply_css("/home/blakec/.cache/wallust/ags-colors.css", false)

    Launcher()

    app.connect("request", (_self: any, args: string[], res: (s: string) => void) => {
      const msg = args[0] ?? ""
      if (msg === "launcher") {
        openAppLauncher(res)
      } else if (msg.startsWith("pick:")) {
        openPicker(msg.slice(5), res)
      } else if (msg.startsWith("pick-image:")) {
        openImagePicker(msg.slice(11), res)
      } else {
        res("unknown command")
      }
    })

    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    const barWindow = (
      <window
        name="bar"
        namespace="bar"
        layer={Astal.Layer.TOP}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        visible
        anchor={TOP | LEFT | RIGHT}
      >
        <centerbox cssClasses={["bar"]} hexpand>
          <box $type="start" hexpand halign={Gtk.Align.START} cssClasses={["bar-left"]}>
            <Workspaces />
            <WindowTitle />
          </box>
          <box $type="center" cssClasses={["bar-center"]}>
            <MusicPlayer />
            <Clock />
          </box>
          <box $type="end" hexpand halign={Gtk.Align.END} cssClasses={["bar-right"]}>
            <Battery />
            <Wifi />
            <SystemConfig />
            <SysInfo />
            <SysTray />
          </box>
        </centerbox>
      </window>
    ) as Astal.Window

    setBarRef(barWindow)
    return barWindow
  },
})
