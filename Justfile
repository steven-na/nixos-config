# ============================================================
#  NixOS Config Justfile
#  Usage: just <recipe>
#         just --list  (see all recipes)
# ============================================================

# Read hostname and username from the system at runtime
hostname  := `hostname`
username  := `whoami`
config_dir := justfile_directory()

# Default recipe — show available commands
default:
    @just --list --unsorted

# ── SYSTEM ──────────────────────────────────────────────────

# Build and switch NixOS system config
[group('system')]
switch:
    sudo nixos-rebuild switch --flake .#{{hostname}}

# Build without switching (good for checking it compiles)
[group('system')]
build:
    nixos-rebuild build --flake .#{{hostname}}

# Switch with full trace output on error
[group('system')]
switch-trace:
    sudo nixos-rebuild switch --flake .#{{hostname}} --show-trace --verbose

# Boot — applies on next reboot only, safer for risky changes
[group('system')]
boot:
    sudo nixos-rebuild boot --flake .#{{hostname}}

# Test — activate config but don't persist across reboots
[group('system')]
test:
    sudo nixos-rebuild test --flake .#{{hostname}}

# Dry-run: show what would change without applying
[group('system')]
dry:
    nixos-rebuild dry-activate --flake .#{{hostname}}

# ── HOME MANAGER ─────────────────────────────────────────────

# Build and switch Home Manager config
[group('home')]
home:
    home-manager switch --flake .#{{username}}@{{hostname}}

# Build HM without switching
[group('home')]
home-build:
    home-manager build --flake .#{{username}}@{{hostname}}

# Switch HM with trace
[group('home')]
home-trace:
    home-manager switch --flake .#{{username}}@{{hostname}} --show-trace --verbose

# List HM news (changelogs for new options)
[group('home')]
home-news:
    home-manager news --flake .#{{username}}@{{hostname}}

# ── BOTH AT ONCE ─────────────────────────────────────────────

# Rebuild system AND home manager in one shot
[group('system')]
rebuild: switch home

# ── FLAKE ────────────────────────────────────────────────────

# Update all flake inputs (nixpkgs, home-manager, hyprland, zen-browser, etc.)
[group('flake')]
update:
    nix flake update

# Update a single input: just update-input home-manager
[group('flake')]
update-input input:
    nix flake update {{input}}

# Show what changed in flake inputs since last lock
[group('flake')]
diff:
    nix flake metadata --json | jq '.locks.nodes | to_entries[] | {key, rev: .value.locked.rev?} | select(.rev != null)'

# Check flake for errors without building
[group('flake')]
check:
    nix flake check

# Show the flake outputs tree
[group('flake')]
show:
    nix flake show

# ── GARBAGE COLLECTION ───────────────────────────────────────

# Remove system generations older than 14 days and garbage collect
[group('gc')]
gc:
    sudo nix profile wipe-history \
        --profile /nix/var/nix/profiles/system \
        --older-than 14d
    sudo nix-collect-garbage --delete-old
    nix-collect-garbage --delete-old

# Nuke everything not referenced by any current generation (aggressive)
[group('gc')]
gc-all:
    sudo nix-collect-garbage -d
    nix-collect-garbage -d

# Show how much space the Nix store is using
[group('gc')]
store-size:
    du -sh /nix/store
    nix store info

# Optimise the store (deduplication via hard links)
[group('gc')]
optimise:
    nix store optimise

# ── GENERATIONS ──────────────────────────────────────────────

# List system generations
[group('generations')]
history:
    nix profile history --profile /nix/var/nix/profiles/system

# List home-manager generations
[group('generations')]
hm-history:
    home-manager generations

# Roll back system to previous generation
[group('generations')]
rollback:
    sudo nixos-rebuild --rollback switch

# Roll back home-manager to previous generation
[group('generations')]
hm-rollback:
    home-manager generations | head -5
    @echo ""
    @echo "Run: home-manager activate <id>"

# ── WALLUST / THEMING ─────────────────────────────────────────

# Apply a wallpaper and regenerate all themes
# Usage: just wall ~/wallpapers/foo.jpg
[group('theme')]
wall path:
    ~/.local/bin/set-wallpaper.sh "{{path}}"

# Pick a random wallpaper from ~/wallpapers and apply it
[group('theme')]
wall-random:
    ~/.local/bin/set-wallpaper.sh \
        "$(find ~/wallpapers -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' \) | shuf -n 1)"

# Pick a wallpaper interactively via fuzzel
[group('theme')]
wall-pick:
    find ~/wallpapers -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' \) \
        | xargs -I{} basename {} \
        | fuzzel --dmenu \
        | xargs -I{} ~/.local/bin/set-wallpaper.sh ~/wallpapers/{}

# Show the current wallust color palette in the terminal
[group('theme')]
palette:
    wallust cs

# Re-run wallust on the current wallpaper without changing it
[group('theme')]
theme-reload:
    #!/usr/bin/env bash
    WP="$(cat ~/.cache/wallust/last-wallpaper 2>/dev/null)"
    if [[ -z "$WP" ]]; then
        echo "No last wallpaper found in ~/.cache/wallust/last-wallpaper"
        exit 1
    fi
    ~/.local/bin/set-wallpaper.sh "$WP"

# Reload just the bar (no wallpaper change)
[group('theme')]
bar-reload:
    pkill -SIGUSR2 waybar || true

# ── HYPRLAND ─────────────────────────────────────────────────

# Reload hyprland config
[group('hypr')]
hypr-reload:
    hyprctl reload

# Show all connected monitors and their properties
[group('hypr')]
monitors:
    hyprctl -j monitors | jq

# Show all open windows and their classes (useful for writing window rules)
[group('hypr')]
clients:
    hyprctl -j clients | jq '[.[] | {class, title, workspace: .workspace.name}]'

# Show all workspaces
[group('hypr')]
workspaces:
    hyprctl -j workspaces | jq '[.[] | {id, name, windows}]'

# Show current Hyprland version
[group('hypr')]
hypr-version:
    hyprctl version

# Show Hyprland config parse errors (quick debug)
[group('hypr')]
hypr-errors:
    hyprctl configerrors

# Follow the live Hyprland log
[group('hypr')]
hypr-log:
    hyprctl rollinglog --follow

# Live event stream from Hyprland socket2 (needs socat)
[group('hypr')]
hypr-events:
    socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

# ── NIX REPL / DEBUG ─────────────────────────────────────────

# Open a nix repl with the flake loaded (lets you explore packages/options)
[group('dev')]
repl:
    nix repl --expr 'builtins.getFlake "path:{{config_dir}}"'

# Search nixpkgs for a package name
# Usage: just search ripgrep
[group('dev')]
search pkg:
    nix search nixpkgs {{pkg}}

# Open the config directory in your editor
[group('dev')]
edit:
    $EDITOR {{config_dir}}

# Show all packages installed in the current system profile
[group('dev')]
pkgs:
    nix profile list --profile /nix/var/nix/profiles/system

# Show the store path of a built package
# Usage: just path foot
[group('dev')]
path pkg:
    nix build nixpkgs#{{pkg}} --no-link --print-out-paths

# Evaluate a nix expression quickly
# Usage: just eval 'pkgs.foot.version'
[group('dev')]
eval expr:
    nix eval nixpkgs#{{expr}}

# Run a package without installing (nix shell)
# Usage: just run neofetch
[group('dev')]
run pkg:
    nix run nixpkgs#{{pkg}}

# ── GIT ──────────────────────────────────────────────────────

# Commit all changes with a message
# Usage: just commit "add foot config"
[group('git')]
commit msg:
    git -C {{config_dir}} add -A
    git -C {{config_dir}} commit -m "{{msg}}"

# Push to remote
[group('git')]
push:
    git -C {{config_dir}} push

# Commit and push in one step
# Usage: just save "tweak waybar"
[group('git')]
save msg: (commit msg) push

# Show git log (short)
[group('git')]
log:
    git -C {{config_dir}} log --oneline --graph --decorate -20

# Show uncommitted diff
[group('git')]
diff-git:
    git -C {{config_dir}} diff

# ── BOOTSTRAP (first-time setup) ─────────────────────────────

# First-time: create wallpapers dir and seed a default wallpaper cache entry
[group('bootstrap')]
init:
    mkdir -p ~/wallpapers ~/.cache/wallust ~/.local/bin
    @echo "Drop a wallpaper into ~/wallpapers/, then run: just wall ~/wallpapers/<file>"
    @echo "After that, run: just switch && just home"

# Copy hardware config from /etc/nixos into the repo
[group('bootstrap')]
get-hw:
    cp /etc/nixos/hardware-configuration.nix \
        {{config_dir}}/hosts/{{hostname}}/hardware-configuration.nix
    @echo "hardware-configuration.nix copied. Review it, then commit."

# ── MISC ─────────────────────────────────────────────────────

# Show system info
[group('misc')]
info:
    @echo "Hostname : {{hostname}}"
    @echo "Username : {{username}}"
    @echo "Config   : {{config_dir}}"
    @echo "Nix      : $(nix --version)"
    @echo "Channel  : nixos-unstable"
    hyprctl version | head -1

# Check if there are any config errors before switching
[group('misc')]
lint:
    nix flake check --no-build
    @echo "✓ Flake checks passed"
    statix check {{config_dir}} 2>/dev/null || echo "(install statix for deeper linting)"
    deadnix {{config_dir}} 2>/dev/null || echo "(install deadnix to find unused bindings)"
