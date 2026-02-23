{ pkgs, ... }:
{
    imports = [
        ./binds.nix
        ./rules.nix
        ./styling.nix

        ./hypridle.nix
        ./hyprlock.nix
        # ./hyprpaper.nix
        ./swww.nix
        ./waybar.nix
    ];

    wayland.windowManager.hyprland = {
        enable = true;

        systemd.variables = [ "--all" ];
        extraConfig = # hyprlang
            ''
                monitor=desc:BOE NE160WUM-NX2, 1920x1200@165, 0x0, 1
                monitor=desc:ASUSTek COMPUTER INC VG259QM SALMQS078467, 1920x1080@144, auto, 1, transform, 1
            '';
        settings = {
            exec-once = [
                "waybar"
                "mako"
                # "hyprpaper"
                "swww-daemon"
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

            cursor = {
                no_hardware_cursors = 1;
            };

            debug = {
                disable_logs = false;
            };

            env = [
                "WLR_NO_HARDWARE_CURSORS,1"
                "EGL_PLATFORM,wayland"
                "OZONE_PLATFORM,wayland"
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
        plugins = [
            # pkgs.hyprlandPlugins.hypr-dynamic-cursors
        ];
    };
}
