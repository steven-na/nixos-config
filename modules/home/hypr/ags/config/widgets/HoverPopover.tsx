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
  trigger,
  cssClasses = [],
  align = "end",
  children,
}: {
  iconName?: string
  label?: string
  trigger?: Gtk.Widget
  cssClasses?: string[]
  align?: "start" | "end"
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
    popupWindow.marginTop = barHeight
    const triggerLeft = Math.round(point.x)
    const triggerRight = triggerLeft + trigger.get_width()

    function computeMarginLeft(popupWidth: number): number {
      if (align === "start") {
        return triggerLeft
      }
      return Math.max(0, triggerRight - popupWidth)
    }

    // If we already know the popup width from a previous show, position immediately
    const knownWidth = borderWrapper.get_width()
    if (knownWidth > 0) {
      popupWindow.marginLeft = computeMarginLeft(knownWidth)
      popupWindow.visible = true
      revealer.revealChild = true
      return
    }

    // Measure natural width before showing — works pre-map unlike get_width()
    const [, natWidth] = borderWrapper.measure(Gtk.Orientation.HORIZONTAL, -1)
    if (natWidth > 0) {
      popupWindow.marginLeft = computeMarginLeft(natWidth)
    }
    popupWindow.visible = true
    revealer.revealChild = true
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
      {trigger ? trigger : triggerLabel ? <label label={triggerLabel} /> : <image iconName={iconName!} />}
    </box>
  )
}
