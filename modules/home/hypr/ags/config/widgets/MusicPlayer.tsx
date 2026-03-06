import AstalMpris from "gi://AstalMpris"
import GdkPixbuf from "gi://GdkPixbuf"
import Gdk from "gi://Gdk"
import Pango from "gi://Pango"
import Soup from "gi://Soup?version=3.0"
import Gio from "gi://Gio"
import GLib from "gi://GLib"
import { Gtk } from "ags/gtk4"
import { createBinding, createComputed, With } from "ags"
import HoverPopover from "./HoverPopover"

const ART_MAX_WIDTH = 250
const COVER_CACHE = GLib.get_user_cache_dir() + "/astal/mpris"

function fetchCoverArt(
  artUrl: string,
  callback: (path: string | null) => void,
) {
  const hash = GLib.compute_checksum_for_string(GLib.ChecksumType.SHA1, artUrl, -1)
  const path = COVER_CACHE + "/" + hash

  if (GLib.file_test(path, GLib.FileTest.EXISTS)) {
    callback(path)
    return
  }

  if (!GLib.file_test(COVER_CACHE, GLib.FileTest.IS_DIR)) {
    Gio.File.new_for_path(COVER_CACHE).make_directory_with_parents(null)
  }

  const session = new Soup.Session()
  const msg = new Soup.Message({ method: "GET", uri: GLib.Uri.parse(artUrl, GLib.UriFlags.NONE) })

  session.send_and_read_async(msg, GLib.PRIORITY_DEFAULT, null, (_session: any, res: Gio.AsyncResult) => {
    try {
      const bytes = session.send_and_read_finish(res)
      if (msg.get_status() === Soup.Status.OK && bytes) {
        const file = Gio.File.new_for_path(path)
        file.replace_contents(bytes.get_data(), null, false, Gio.FileCreateFlags.REPLACE_DESTINATION, null)
        callback(path)
      } else {
        callback(null)
      }
    } catch (e) {
      console.error("Failed to fetch cover art:", e)
      callback(null)
    }
  })
}

const MARQUEE_WINDOW = 30
const MARQUEE_SEPARATOR = "   \u2022   "
const MARQUEE_INTERVAL = 300
const MARQUEE_PAUSE = 2000

let selectedBusName: string | null = null

function getActivePlayers(players: AstalMpris.Player[]): AstalMpris.Player[] {
  return players.filter(
    (p) =>
      p.playbackStatus === AstalMpris.PlaybackStatus.PLAYING ||
      p.playbackStatus === AstalMpris.PlaybackStatus.PAUSED,
  )
}

function pickPlayer(players: AstalMpris.Player[]): AstalMpris.Player | null {
  const active = getActivePlayers(players)
  if (active.length === 0) return players[0] || null
  if (selectedBusName) {
    const match = active.find((p) => p.busName === selectedBusName)
    if (match) return match
  }
  return active[0]
}

function MarqueeLabel({ player, prop }: { player: AstalMpris.Player; prop: "title" | "artist" | "album" }) {
  const lbl = new Gtk.Label({
    halign: Gtk.Align.START,
    cssClasses: ["music-marquee-label"],
    maxWidthChars: MARQUEE_WINDOW,
    widthChars: MARQUEE_WINDOW,
    xalign: 0,
    ellipsize: Pango.EllipsizeMode.NONE,
  })

  let text = ""
  let offset = 0
  let scrollTimer: ReturnType<typeof setInterval> | null = null
  let pauseTimer: ReturnType<typeof setTimeout> | null = null
  let mapped = false

  function updateDisplay() {
    if (text.length <= MARQUEE_WINDOW) {
      lbl.label = text
      return
    }
    const circular = text + MARQUEE_SEPARATOR
    let display = ""
    for (let i = 0; i < MARQUEE_WINDOW; i++) {
      display += circular[(offset + i) % circular.length]
    }
    lbl.label = display
  }

  function stopScroll() {
    if (scrollTimer !== null) {
      clearInterval(scrollTimer)
      scrollTimer = null
    }
    if (pauseTimer !== null) {
      clearTimeout(pauseTimer)
      pauseTimer = null
    }
  }

  function startScroll() {
    stopScroll()
    offset = 0
    updateDisplay()
    if (text.length <= MARQUEE_WINDOW) return

    pauseTimer = setTimeout(() => {
      scrollTimer = setInterval(() => {
        const circular = text + MARQUEE_SEPARATOR
        offset = (offset + 1) % circular.length
        updateDisplay()
        if (offset === 0) {
          stopScroll()
          pauseTimer = setTimeout(() => startScroll(), MARQUEE_PAUSE)
        }
      }, MARQUEE_INTERVAL)
    }, MARQUEE_PAUSE)
  }

  function onTextChanged() {
    const val = (player as any)[prop] || ""
    if (val === text) return
    text = val
    offset = 0
    if (mapped) startScroll()
    else updateDisplay()
  }

  player.connect(`notify::${prop}`, onTextChanged)
  onTextChanged()

  lbl.connect("map", () => {
    mapped = true
    startScroll()
  })
  lbl.connect("unmap", () => {
    mapped = false
    stopScroll()
    offset = 0
    updateDisplay()
  })

  return lbl
}

function SourceLabel({ player }: { player: AstalMpris.Player }) {
  const identity = player.identity || "Unknown"
  const iconMap: Record<string, string> = {
    "Spotify": "spotify-symbolic",
    "Mozilla Firefox": "firefox-symbolic",
    "Firefox": "firefox-symbolic",
    "Chromium": "chromium-symbolic",
    "Google Chrome": "google-chrome-symbolic",
    "VLC media player": "vlc-symbolic",
  }
  const iconName = iconMap[identity] || "multimedia-player-symbolic"

  return (
    <box cssClasses={["music-source"]} spacing={6} halign={Gtk.Align.CENTER}>
      <image iconName={iconName} pixelSize={14} />
      <label label={identity} cssClasses={["music-source-label"]} />
    </box>
  )
}

function ProgressBar({ player }: { player: AstalMpris.Player }) {
  const scale = new Gtk.Scale({
    orientation: Gtk.Orientation.HORIZONTAL,
    cssClasses: ["music-progress"],
    drawValue: false,
    hexpand: true,
  })

  const adj = scale.get_adjustment()
  adj.set_lower(0)
  adj.set_value(0)
  adj.set_upper(player.length > 0 ? player.length : 1)

  let timer: ReturnType<typeof setInterval> | null = null
  let seeking = false

  player.connect("notify::length", () => {
    const len = player.length
    adj.set_upper(len > 0 ? len : 1)
  })

  scale.connect("change-value", (_self: Gtk.Scale, _scroll: Gtk.ScrollType, value: number) => {
    seeking = true
    player.position = Math.max(0, Math.min(value, adj.get_upper()))
    setTimeout(() => { seeking = false }, 200)
    return false
  })

  scale.connect("map", () => {
    adj.set_value(player.position || 0)
    timer = setInterval(() => {
      if (!seeking) {
        adj.set_value(player.position || 0)
      }
    }, 1000)
  })

  scale.connect("unmap", () => {
    if (timer !== null) {
      clearInterval(timer)
      timer = null
    }
  })

  return scale
}

function ShuffleButton({ player }: { player: AstalMpris.Player }) {
  const binding = createBinding(player, "shuffleStatus")

  return (
    <button
      onClicked={() => player.shuffle()}
      visible={binding((s: AstalMpris.Shuffle) => s !== AstalMpris.Shuffle.UNSUPPORTED)}
      cssClasses={binding((s: AstalMpris.Shuffle) =>
        s === AstalMpris.Shuffle.ON
          ? ["music-toggle", "active"]
          : ["music-toggle"],
      )}
    >
      <image iconName="media-playlist-shuffle-symbolic" />
    </button>
  )
}

function LoopButton({ player }: { player: AstalMpris.Player }) {
  const binding = createBinding(player, "loopStatus")

  return (
    <button
      onClicked={() => player.loop()}
      visible={binding((s: AstalMpris.Loop) => s !== AstalMpris.Loop.UNSUPPORTED)}
      cssClasses={binding((s: AstalMpris.Loop) =>
        s === AstalMpris.Loop.TRACK || s === AstalMpris.Loop.PLAYLIST
          ? ["music-toggle", "active"]
          : ["music-toggle"],
      )}
    >
      <image
        iconName={binding((s: AstalMpris.Loop) =>
          s === AstalMpris.Loop.TRACK
            ? "media-playlist-repeat-song-symbolic"
            : "media-playlist-repeat-symbolic",
        )}
      />
    </button>
  )
}

function PlayerControls({ player }: { player: AstalMpris.Player }) {
  const statusBinding = createBinding(player, "playbackStatus")

  const picture = new Gtk.Picture({
    contentFit: Gtk.ContentFit.COVER,
    canShrink: true,
    hexpand: false,
    cssClasses: ["music-art"],
  })

  function loadPicture(path: string) {
    try {
      const pixbuf = GdkPixbuf.Pixbuf.new_from_file(path)
      if (!pixbuf) return
      const w = pixbuf.get_width()
      const h = pixbuf.get_height()
      if (w > ART_MAX_WIDTH) {
        const scale = ART_MAX_WIDTH / w
        const scaled = pixbuf.scale_simple(ART_MAX_WIDTH, Math.round(h * scale), GdkPixbuf.InterpType.BILINEAR)
        if (scaled) {
          picture.set_paintable(Gdk.Texture.new_for_pixbuf(scaled))
          return
        }
      }
      picture.set_paintable(Gdk.Texture.new_for_pixbuf(pixbuf))
    } catch {
      picture.set_paintable(null)
    }
  }

  function updateArt() {
    const url = player.artUrl
    // For HTTP URLs, skip Astal's internal caching (which can fail with
    // CRITICAL errors) and use our own fetchCoverArt() directly.
    if (url && url.startsWith("http")) {
      fetchCoverArt(url, (cachedPath) => {
        if (cachedPath) loadPicture(cachedPath)
        else picture.set_paintable(null)
      })
      return
    }
    // For local paths, prefer Astal's coverArt (resolved local path)
    const path = player.coverArt
    if (path) {
      loadPicture(path)
      return
    }
    if (url) {
      loadPicture(url)
      return
    }
    picture.set_paintable(null)
  }
  player.connect("notify::cover-art", updateArt)
  player.connect("notify::art-url", updateArt)
  updateArt()

  const artContainer = (
    <box
      cssClasses={["music-art-container"]}
      visible={createComputed(() => {
        const cover = createBinding(player, "coverArt")()
        const url = createBinding(player, "artUrl")()
        return !!(cover || (url && url.startsWith("http")))
      })}
    >
      {picture}
    </box>
  )

  return (
    <box cssClasses={["music-popover"]} orientation={Gtk.Orientation.VERTICAL} spacing={8}>
      <SourceLabel player={player} />
      {artContainer}
      <box orientation={Gtk.Orientation.VERTICAL} spacing={2}>
        <MarqueeLabel player={player} prop="title" />
        <MarqueeLabel player={player} prop="artist" />
        <MarqueeLabel player={player} prop="album" />
      </box>
      <ProgressBar player={player} />
      <box cssClasses={["music-controls"]} halign={Gtk.Align.CENTER} spacing={8}>
        <ShuffleButton player={player} />
        <button
          onClicked={() => player.previous()}
          sensitive={createBinding(player, "canGoPrevious") as any}
        >
          <image iconName="media-skip-backward-symbolic" />
        </button>
        <button onClicked={() => player.play_pause()}>
          <image
            iconName={statusBinding((s: AstalMpris.PlaybackStatus) =>
              s === AstalMpris.PlaybackStatus.PLAYING
                ? "media-playback-pause-symbolic"
                : "media-playback-start-symbolic",
            )}
          />
        </button>
        <button
          onClicked={() => player.next()}
          sensitive={createBinding(player, "canGoNext") as any}
        >
          <image iconName="media-skip-forward-symbolic" />
        </button>
        <LoopButton player={player} />
      </box>
    </box>
  )
}

export default function MusicPlayer() {
  const mpris = AstalMpris.get_default()
  const players = createBinding(mpris, "players")

  return (
    <With value={players}>
      {(list: AstalMpris.Player[]) => {
        const player = pickPlayer(list)
        if (!player) return <box visible={false} />

        const active = getActivePlayers(list)
        const hasMultiple = active.length > 1
        const currentIdx = active.findIndex((p) => p.busName === player.busName)
        const playerCountText = hasMultiple ? `${currentIdx + 1}/${active.length}` : ""

        const titleBinding = createBinding(player, "title")
        const artistBinding = createBinding(player, "artist")
        const displayLabel = createComputed(() => {
          const t = titleBinding()
          const a = artistBinding()
          if (a && t) return `${a} - ${t}`
          return t || a || ""
        })

        const clickGesture = new Gtk.GestureClick()
        clickGesture.connect("released", () => {
          const currentActive = getActivePlayers(list)
          if (currentActive.length < 2) return
          const idx = currentActive.findIndex((p) => p.busName === player.busName)
          const nextIdx = (idx + 1) % currentActive.length
          selectedBusName = currentActive[nextIdx].busName
          mpris.notify("players")
        })

        const triggerBox = (
          <box
            spacing={4}
            $={(self: Gtk.Box) => self.add_controller(clickGesture)}
          >
            <label
              label={displayLabel}
              ellipsize={Pango.EllipsizeMode.END}
              maxWidthChars={30}
            />
            <label
              label={playerCountText}
              visible={hasMultiple}
              cssClasses={["music-player-count"]}
            />
          </box>
        )

        return (
          <HoverPopover
            trigger={triggerBox}
            cssClasses={["music-player"]}
          >
            <PlayerControls player={player} />
          </HoverPopover>
        )
      }}
    </With>
  )
}
