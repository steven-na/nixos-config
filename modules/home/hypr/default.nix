{ pkgs, ... }:
{
    imports = [
        ./binds.nix
        ./rules.nix
        ./styling.nix
    ];

    wayland.windowManager.hyprland = {
        settings = {
            monitor = [
                "desc:BOE NE160WUM-NX2, 1920x1200@165, 0x0, 1"
                "desc:ASUSTek COMPUTER INC VG259QM SALMQS078467, 1920x1080@240, 1920x0, 0.8, transform, 1"
            ];

            exec-once = [
                "waybar"
                "mako"
                "hyprpaper"
                "hypridle"
                "hyprpolkitagent"
                # run wallust on last used wallpaper at login
                "~/.local/bin/set-wallpaper.sh $(cat ~/.cache/wallust/last-wallpaper)"
                "discord"
                "spotify"
                "obsidian"
            ];

            general = {
                layout = "dwindle";
            };

            binds.movefocus_cycles_fullscreen = 1;

            env = [
                "env = WLR_NO_HARDWARE_CURSORS,1"
                "EGL_PLAYFORM=wayland"
                "OZONE_PLAYFORM=wayland"
            ];
            plugins = [
                pkgs.hyprlandPlugins.hypr-dynamic-cursors
            ];

            dwindle = {
                pseudotile = true;
                preserve_split = true;
            };

            input = {
                kb_layout = "us";
                follow_mouse = 1;
                special_fallthrough = true;
            };

            misc = {
                disable_hyprland_logo = true;
                disable_splash_rendering = true;
                font_family = "JetBrainsMono Nerd Font";
                vfr = 1;
                vrr = 1;
                enable_swallow = true;
            };
        };
    };
}
