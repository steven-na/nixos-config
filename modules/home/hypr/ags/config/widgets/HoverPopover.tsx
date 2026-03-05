import { Astal, Gtk } from "ags/gtk4"
import { onCleanup } from "ags"
import app from "ags/gtk4/app"
import Graphene from "gi://Graphene"

function hasActiveMenuPopover(widget: Gtk.Widget): boolean {
  if (widget instanceof Gtk.MenuButton) {
    const p = widget.get_popover()
    if (p && p.get_visible()) return true
  }
  let child = widget.get_first_child()
  while (child) {
    if (hasActiveMenuPopover(child)) return true
    child = child.get_next_sibling()
  }
  return false
}

export default function HoverPopover({
  iconName,
  label: triggerLabel,
  cssClasses = [],
  children,
}: {
  iconName?: string
  label?: string
  cssClasses?: string[]
  children: Gtk.Widget
}) {
  let leaveTimer: ReturnType<typeof setTimeout> | null = null

  function cancelLeave() {
    if (leaveTimer !== null) {
      clearTimeout(leaveTimer)
      leaveTimer = null
    }
  }

  onCleanup(() => cancelLeave())

  const { TOP, LEFT } = Astal.WindowAnchor

  const revealer = new Gtk.Revealer({
    transitionType: Gtk.RevealerTransitionType.SLIDE_DOWN,
    transitionDuration: 150,
    revealChild: false,
  })

  const innerBox = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    cssClasses: ["popup-inner"],
  })
  innerBox.append(children)
  revealer.set_child(innerBox)

  const borderWrapper = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    cssClasses: ["popup-border-wrapper"],
  })
  borderWrapper.append(revealer)

  const popupWindow = new Astal.Window({
    namespace: "hover-popup",
    layer: Astal.Layer.TOP,
    exclusivity: Astal.Exclusivity.IGNORE,
    anchor: TOP | LEFT,
    visible: false,
    application: app,
    cssClasses: ["hover-popup-window"],
    child: borderWrapper,
    keymode: Astal.Keymode.NONE,
  })

  revealer.connect("notify::child-revealed", () => {
    if (!revealer.revealChild && !revealer.childRevealed) {
      popupWindow.visible = false
    }
  })

  function show(trigger: Gtk.Widget) {
    cancelLeave()

    const root = trigger.get_root()
    if (!root) return

    const [ok, point] = trigger.compute_point(
      root as Gtk.Widget,
      new Graphene.Point({ x: 0, y: 0 }),
    )
    if (!ok) return

    const barHeight = (root as Gtk.Widget).get_height()
    // Flush with bar bottom — bar border acts as popup's top border
    popupWindow.marginTop = barHeight
    // Temporarily position at trigger's left edge
    const triggerRight = Math.round(point.x) + trigger.get_width()
    popupWindow.marginLeft = triggerRight
    popupWindow.visible = true

    setTimeout(() => {
      // Right-align popup to trigger's right edge
      const popupWidth = borderWrapper.get_width()
      if (popupWidth > 0) {
        popupWindow.marginLeft = Math.max(0, triggerRight - popupWidth)
      }
      revealer.revealChild = true
    }, 0)
  }

  function scheduleClose() {
    cancelLeave()
    leaveTimer = setTimeout(function tryClose() {
      if (hasActiveMenuPopover(borderWrapper)) {
        leaveTimer = setTimeout(tryClose, 300)
        return
      }
      revealer.revealChild = false
    }, 300)
  }

  return (
    <box
      cssClasses={cssClasses}
      $={(self: Gtk.Box) => {
        const motion = new Gtk.EventControllerMotion()
        motion.connect("enter", () => show(self))
        motion.connect("leave", () => scheduleClose())
        self.add_controller(motion)

        const popupMotion = new Gtk.EventControllerMotion()
        popupMotion.connect("enter", () => cancelLeave())
        popupMotion.connect("leave", () => scheduleClose())
        popupWindow.add_controller(popupMotion)

        onCleanup(() => popupWindow.destroy())
      }}
    >
      {triggerLabel ? <label label={triggerLabel} /> : <image iconName={iconName!} />}
    </box>
  )
}
