{ pkgs, ... }:
{
    home.packages = [ pkgs.wallust ];

    # Main wallust config
    xdg.configFile."wallust/wallust.toml".text = ''
              backend = "full"
              color_space = "lab-mixed"
              palette = "dark16"
              threshold = 11
              check_contrast = true

        [templates.waybar-colors]
        template = "waybar-colors.css"
        target = "~/.config/waybar/colors.css"

        [templates.foot-colors]
        template = "foot-colors.ini"
        target = "~/.cache/wallust/foot-colors.ini"

        [templates.fuzzel]
        template = "fuzzel.ini"
        target = "~/.config/fuzzel/fuzzel.ini"

        [templates.mako]
        template = "mako-colors"
        target = "~/.cache/wallust/mako-colors"

        [templates.discord]
        template = "discord.css"
        target = "~/.cache/wallust/discord-colors.css"

        [templates.hyprland]
        template = "hyprland-colors.conf"
        target = "~/.cache/wallust/hyprland-colors.conf"

        [templates.zen]
        template = "zen-colors.css"
        target = "~/.cache/wallust/zen-colors.css"
    ''; # ── Waybar CSS template ──────────────────────────────────────────────
    xdg.configFile."wallust/templates/waybar-colors.css".text = ''
        @define-color background  {{background}};
        @define-color foreground  {{foreground}};
        @define-color cursor      {{cursor}};
        @define-color color0      {{color0}};
        @define-color color1      {{color1}};
        @define-color color2      {{color2}};
        @define-color color3      {{color3}};
        @define-color color4      {{color4}};
        @define-color color5      {{color5}};
        @define-color color6      {{color6}};
        @define-color color7      {{color7}};
        @define-color color8      {{color8}};
        @define-color color9      {{color9}};
        @define-color color10     {{color10}};
        @define-color color11     {{color11}};
        @define-color color12     {{color12}};
        @define-color color13     {{color13}};
        @define-color color14     {{color14}};
        @define-color color15     {{color15}};
    '';

    # ── foot-colors.ini ─────────────────────────────────────────────────
    xdg.configFile."wallust/templates/foot-colors.ini".text = ''
        [colors]
        alpha=0.85
        background={{ background | strip }}
        foreground={{ foreground | strip }}
        regular0={{ color0 | strip }}
        regular1={{ color1 | strip }}
        regular2={{ color2 | strip }}
        regular3={{ color3 | strip }}
        regular4={{ color4 | strip }}
        regular5={{ color5 | strip }}
        regular6={{ color6 | strip }}
        regular7={{ color7 | strip }}
        bright0={{ color8 | strip }}
        bright1={{ color9 | strip }}
        bright2={{ color10 | strip }}
        bright3={{ color11 | strip }}
        bright4={{ color12 | strip }}
        bright5={{ color13 | strip }}
        bright6={{ color14 | strip }}
        bright7={{ color15 | strip }}
    '';

    # ── fuzzel.ini ───────────────────────────────────────────────────────
    xdg.configFile."wallust/templates/fuzzel.ini".text = ''
        [main]
        font=JetBrainsMono Nerd Font:size=12
        icon-theme=Papirus-Dark
        icons-enabled=yes
        terminal=foot
        width=35
        lines=10
        prompt=❯ 
        fuzzy=yes
        anchor=center
        layer=overlay

        [border]
        width=2
        radius=8

        [dmenu]
        exit-immediately-if-empty=yes

        [colors]
        background={{ background | strip }}cc
        text={{ foreground | strip }}ff
        match={{ color2 | strip }}ff
        selection={{ color1 | strip }}cc
        selection-text={{ background | strip }}ff
        selection-match={{ color2 | strip }}ff
        border={{ color1 | strip }}ff
    '';

    # ── hyprland-colors.conf ─────────────────────────────────────────────
    xdg.configFile."wallust/templates/hyprland-colors.conf".text = ''
        general {
          col.active_border = rgba({{ color1 | strip }}ff) rgba({{ color2 | strip }}ff) 45deg
          col.inactive_border = rgba({{ color0 | strip }}00)
        }
        decoration {
          shadow {
            color = rgba({{ color0 | strip }}ee)
          }
        }
    '';

    # ── Mako colors template ─────────────────────────────────────────────
    xdg.configFile."wallust/templates/mako-colors".text = ''
        background-color={{background}}cc
        text-color={{foreground}}ff
        border-color={{color1}}ff

        [urgency=low]
        border-color={{color2}}ff

        [urgency=high]
        border-color={{color9}}ff
        background-color={{color1}}cc
    '';

    # ── Discord/Vesktop CSS template ─────────────────────────────────────
    xdg.configFile."wallust/templates/discord.css".text = ''

        @import url('https://s-k-y-l-i.github.io/discord-themes/Theme%20code/responsive.css');

        --color0:  {{ color0 }};
        --color1:  {{ color1 }};
        --color2:  {{ color0 }};
        --color3:  {{ color3 }};
        --color4:  {{ color4 }};
        --color5:  {{ color5 }};
        --color6:  {{ color6 }};
        --color7:  {{ color7 }};
        --color8:  {{ background }};
        --color9:  {{ color9 }};
        --color10: {{ color10 }};
        --color11: {{ color11 }};
        --color12: {{ color12 }};
        --color13: {{color13 }};
        --color14: {{color9 }};
        --color15: {{ foreground }};
    '';

    # ── Zen Browser CSS variables template ───────────────────────────────
    xdg.configFile."wallust/templates/zen-colors.css".text = ''
        :root {
          --zen-primary-color:          {{color1}};
          --zen-secondary-color:        {{color2}};
          --toolbar-bgcolor:            {{background}};
          --toolbar-color:              {{foreground}};
          --toolbarbutton-hover-background: {{color8}};
          --toolbarbutton-active-background: {{color1}}44;
          --urlbar-background:          {{color0}};
          --urlbar-color:               {{foreground}};
          --tab-selected-bgcolor:       {{color1}};
          --tab-selected-color:         {{background}};
          --sidebar-background-color:   {{color0}};
        }
    '';

    # ── Wallpaper setter script ───────────────────────────────────────────
    home.file.".local/bin/set-wallpaper.sh" = {
        force = true;
        executable = true;
        text = # bash
            ''
                #!/usr/bin/env bash
                set -euo pipefail

                WALLPAPER="$(realpath "$1")"

                if [[ ! -f "$WALLPAPER" ]]; then
                  echo "Error: file not found: $WALLPAPER" >&2
                  exit 1
                fi

                echo "$WALLPAPER" > ~/.cache/wallust/last-wallpaper

                # Generate palette and render all templates
                wallust run "$WALLPAPER"

                # Reload waybar
                pkill -SIGUSR2 waybar 2>/dev/null || true

                # Reload mako
                makoctl reload 2>/dev/null || true

                # Reload hyprland (picks up new hyprland-colors.conf)
                hyprctl reload 2>/dev/null || true

                # Update discord theme
                themecord -w

                # Swap wallpaper on all monitors via hyprpaper IPC
                # if pgrep -x hyprpaper > /dev/null; then
                #   # hyprctl hyprpaper preload "$WALLPAPER"
                #   hyprctl -j monitors \
                #     | jq -r '.[].name' \
                #     | while read -r monitor; do
                #         hyprctl hyprpaper wallpaper "$monitor,$WALLPAPER"
                #       done
                # else
                #   echo "hyprpaper not running, skipping IPC" >&2
                # fi
                swww img $WALLPAPER --transition-type center

                notify-send \
                  --app-name="Wallpaper" \
                  "Theme applied" \
                  "$(basename "$WALLPAPER")" \
                  2>/dev/null || true
            '';
    };
    # Ensure cache dir and default wallpaper file exist
    home.file.".cache/wallust/.keep".text = "";
}
