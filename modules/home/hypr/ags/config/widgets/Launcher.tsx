import AstalApps from "gi://AstalApps"
import GdkPixbuf from "gi://GdkPixbuf"
import Gdk from "gi://Gdk"
import Gio from "gi://Gio"
import GLib from "gi://GLib"
import { Astal, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"

type LauncherMode = "app" | "pick" | "pick-image"

let barRef: Gtk.Window | null = null
let launcherWindow: Astal.Window | null = null
let searchEntry: Gtk.SearchEntry | null = null
let listBox: Gtk.Box | null = null
let scrolled: Gtk.ScrolledWindow | null = null
let revealer: Gtk.Revealer | null = null
let selectedIndex = 0
let currentItems: { label: string; value: string; icon?: string }[] = []
let filteredItems: typeof currentItems = []
let mode: LauncherMode = "app"
let resolveRequest: ((s: string) => void) | null = null

const apps = new AstalApps.Apps()

function clearList() {
  if (!listBox) return
  let child = listBox.get_first_child()
  while (child) {
    const next = child.get_next_sibling()
    listBox.remove(child)
    child = next
  }
}

function updateSelection() {
  if (!listBox) return
  let child = listBox.get_first_child()
  let i = 0
  while (child) {
    const classes = i === selectedIndex ? ["launcher-item", "selected"] : ["launcher-item"]
    child.cssClasses = classes
    child = child.get_next_sibling()
    i++
  }

  // Scroll selected item into view
  if (scrolled && listBox) {
    const vadj = scrolled.get_vadjustment()
    const pageSize = vadj.get_page_size()
    const scrollTop = vadj.get_value()
    let targetTop = 0
    let targetHeight = 0
    let child2 = listBox.get_first_child()
    for (let j = 0; child2; j++) {
      if (j === selectedIndex) {
        targetHeight = child2.get_allocated_height()
        break
      }
      targetTop += child2.get_allocated_height()
      child2 = child2.get_next_sibling()
    }
    const targetBottom = targetTop + targetHeight
    if (targetBottom > scrollTop + pageSize) {
      vadj.set_value(targetBottom - pageSize)
    } else if (targetTop < scrollTop) {
      vadj.set_value(targetTop)
    }
  }
}

let renderGeneration = 0

function renderItems() {
  clearList()
  if (!listBox) return

  const items = filteredItems
  const gen = ++renderGeneration
  const pendingImages: { path: string; placeholder: Gtk.Image }[] = []

  for (const item of items) {
    const row = new Gtk.Box({
      cssClasses: ["launcher-item"],
      spacing: 8,
    })

    if (mode === "pick-image") {
      const placeholder = new Gtk.Image({
        iconName: "image-x-generic-symbolic",
        pixelSize: 48,
        cssClasses: ["launcher-image-preview"],
      })
      row.append(placeholder)
      if (item.icon) {
        pendingImages.push({ path: item.icon, placeholder })
      }
    } else if (mode === "app" && item.icon) {
      const img = new Gtk.Image({ iconName: item.icon, pixelSize: 24 })
      row.append(img)
    }

    const lbl = new Gtk.Label({
      label: item.label,
      halign: Gtk.Align.START,
      hexpand: true,
      ellipsize: 3,
    })
    row.append(lbl)
    listBox.append(row)
  }

  selectedIndex = 0
  updateSelection()
  updateScrollHeight()

  // Load images after the UI has painted
  if (pendingImages.length > 0) {
    let idx = 0
    function loadNext() {
      if (gen !== renderGeneration || idx >= pendingImages.length) return
      const { path, placeholder } = pendingImages[idx++]
      loadImageAsync(path, placeholder, () => {
        if (gen === renderGeneration) loadNext()
      })
    }
    // Start a few concurrent loads
    for (let i = 0; i < 3; i++) loadNext()
  }
}

function loadImageAsync(iconPath: string, placeholder: Gtk.Image, done?: () => void) {
  const file = Gio.File.new_for_path(iconPath)
  file.read_async(GLib.PRIORITY_LOW, null, (_file: any, res: Gio.AsyncResult) => {
    try {
      const stream = file.read_finish(res)
      GdkPixbuf.Pixbuf.new_from_stream_at_scale_async(stream, 48, 48, true, null, (_src: any, res2: Gio.AsyncResult) => {
        try {
          const pixbuf = GdkPixbuf.Pixbuf.new_from_stream_finish(res2)
          if (pixbuf) {
            const picture = new Gtk.Picture({
              cssClasses: ["launcher-image-preview"],
            })
            picture.set_paintable(Gdk.Texture.new_for_pixbuf(pixbuf))
            const parent = placeholder.get_parent()
            if (parent instanceof Gtk.Box) {
              parent.insert_child_after(picture, null)
              parent.remove(placeholder)
            }
          }
        } catch {
          // skip broken images
        }
        if (done) done()
      })
    } catch {
      if (done) done()
    }
  })
}

function updateScrollHeight() {
  if (!scrolled || !launcherWindow) return
  const barHeight = barRef ? barRef.get_height() : 0
  const display = Gdk.Display.get_default()
  if (!display) return
  const monitor = display.get_monitors().get_item(0) as Gdk.Monitor | null
  if (!monitor) return
  const geo = monitor.get_geometry()
  const searchHeight = searchEntry ? searchEntry.get_height() || 40 : 40
  const maxHeight = Math.floor(geo.height / 2) - barHeight - searchHeight
  scrolled.maxContentHeight = Math.max(0, maxHeight)
}

function filterItems(query: string) {
  if (mode === "app") {
    if (!query) {
      filteredItems = currentItems.slice(0, 20)
    } else {
      const results = apps.fuzzy_query(query)
      filteredItems = results.map((a) => ({
        label: a.name,
        value: a.name,
        icon: a.iconName,
      }))
    }
  } else {
    if (!query) {
      filteredItems = currentItems
    } else {
      const q = query.toLowerCase()
      filteredItems = currentItems.filter((item) =>
        item.label.toLowerCase().includes(q),
      )
    }
  }
  renderItems()
}

function selectItem() {
  if (filteredItems.length === 0) return

  const item = filteredItems[selectedIndex]
  if (!item) return

  if (mode === "app") {
    const results = apps.fuzzy_query(item.value)
    if (results.length > 0) results[0].launch()
  } else if (resolveRequest) {
    resolveRequest(item.value)
    resolveRequest = null
  }

  closeLauncher()
}

function positionLauncher() {
  if (!launcherWindow) return
  const barHeight = barRef ? barRef.get_height() : 0
  launcherWindow.marginTop = barHeight

  // Center horizontally
  const display = Gdk.Display.get_default()
  if (display) {
    const monitors = display.get_monitors()
    const monitor = monitors.get_item(0) as Gdk.Monitor | null
    if (monitor) {
      const geo = monitor.get_geometry()
      const launcherWidth = 500
      launcherWindow.marginLeft = Math.round((geo.width - launcherWidth) / 2)
    }
  }

  updateScrollHeight()
}

function closeLauncher() {
  if (revealer) {
    revealer.revealChild = false
  } else if (launcherWindow) {
    launcherWindow.visible = false
  }
  if (resolveRequest) {
    resolveRequest("")
    resolveRequest = null
  }
}

export function setBarRef(w: Gtk.Window) {
  barRef = w
}

export function Launcher() {
  searchEntry = new Gtk.SearchEntry({
    cssClasses: ["launcher-search"],
    hexpand: true,
    placeholderText: "Search...",
  })

  listBox = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
  })

  scrolled = new Gtk.ScrolledWindow({
    cssClasses: ["launcher-scroll"],
    hscrollbarPolicy: Gtk.PolicyType.NEVER,
    vscrollbarPolicy: Gtk.PolicyType.AUTOMATIC,
    propagateNaturalHeight: true,
    minContentHeight: 0,
    maxContentHeight: 0,
    child: listBox,
  })

  const container = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    cssClasses: ["launcher"],
    widthRequest: 500,
  })
  container.append(searchEntry)
  container.append(scrolled)

  searchEntry.connect("search-changed", () => {
    filterItems(searchEntry!.text)
  })

  // Intercept keys on the search entry so Enter isn't swallowed
  const keyController = new Gtk.EventControllerKey()
  keyController.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
  keyController.connect("key-pressed", (_self: any, keyval: number, _keycode: number, state: number) => {
    if (keyval === Gdk.KEY_Escape) {
      closeLauncher()
      return true
    }
    const ctrl = state & Gdk.ModifierType.CONTROL_MASK
    if (keyval === Gdk.KEY_Down || (keyval === Gdk.KEY_n && ctrl)) {
      if (selectedIndex < filteredItems.length - 1) {
        selectedIndex++
        updateSelection()
      }
      return true
    }
    if (keyval === Gdk.KEY_Up || (keyval === Gdk.KEY_p && ctrl)) {
      if (selectedIndex > 0) {
        selectedIndex--
        updateSelection()
      }
      return true
    }
    if (keyval === Gdk.KEY_Return || keyval === Gdk.KEY_KP_Enter) {
      selectItem()
      return true
    }
    return false
  })

  const innerBox = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    cssClasses: ["popup-inner"],
  })
  innerBox.append(container)

  revealer = new Gtk.Revealer({
    transitionType: Gtk.RevealerTransitionType.SLIDE_DOWN,
    transitionDuration: 150,
    revealChild: false,
  })
  revealer.set_child(innerBox)

  const borderWrapper = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    cssClasses: ["popup-border-wrapper"],
  })
  borderWrapper.append(revealer)

  const { TOP, LEFT } = Astal.WindowAnchor

  launcherWindow = new Astal.Window({
    namespace: "launcher",
    layer: Astal.Layer.TOP,
    exclusivity: Astal.Exclusivity.IGNORE,
    keymode: Astal.Keymode.ON_DEMAND,
    anchor: TOP | LEFT,
    visible: false,
    application: app,
    cssClasses: ["hover-popup-window"],
    child: borderWrapper,
  })
  launcherWindow.add_controller(keyController)

  revealer.connect("notify::child-revealed", () => {
    if (!revealer!.revealChild && !revealer!.childRevealed) {
      launcherWindow!.visible = false
    }
  })

  launcherWindow.connect("map", () => {
    if (searchEntry) {
      searchEntry.text = ""
      searchEntry.grab_focus()
    }
  })
}

export function openAppLauncher(respond?: (s: string) => void) {
  mode = "app"
  if (respond) resolveRequest = respond
  const appList = apps.get_list()
  currentItems = appList.map((a) => ({
    label: a.name,
    value: a.name,
    icon: a.iconName,
  }))
  filteredItems = currentItems.slice(0, 20)

  if (searchEntry) searchEntry.text = ""
  renderItems()
  positionLauncher()
  if (launcherWindow) {
    launcherWindow.visible = true
    if (revealer) revealer.revealChild = true
  }
}

export function openPicker(items: string, respond: (s: string) => void) {
  mode = "pick"
  resolveRequest = respond
  currentItems = items.split("\n").map((l) => l.trim()).filter((l) => l.length > 0).map((l) => ({
    label: l,
    value: l,
  }))
  filteredItems = currentItems

  if (searchEntry) searchEntry.text = ""
  renderItems()
  positionLauncher()
  if (launcherWindow) {
    launcherWindow.visible = true
    if (revealer) revealer.revealChild = true
  }
}

export function openImagePicker(items: string, respond: (s: string) => void) {
  mode = "pick-image"
  resolveRequest = respond
  currentItems = items.split("\n").map((l) => l.trim()).filter((l) => l.length > 0).map((l) => ({
    label: l.split("/").pop() || l,
    value: l,
    icon: l,
  }))
  filteredItems = currentItems

  if (searchEntry) searchEntry.text = ""
  renderItems()
  positionLauncher()
  if (launcherWindow) {
    launcherWindow.visible = true
    if (revealer) revealer.revealChild = true
  }
}
