{ ... }:
{
    wayland.windowManager.hyprland.settings = {

        "$mainMod" = "SUPER";

        bind = [

            # Window actions
            "$mainMod, C, killactive"
            "$mainMod, J, togglesplit"
            "$mainMod CTRL, V, togglefloating"
            "$mainMod, F, fullscreen, 1"
            "$mainMod CTRL, F, fullscreen, 0"

            # Exec binds
            "$mainMod, Q, exec, foot"
            "$mainMod, M, exec, foot -e yazi"
            "$mainMod, R, exec, fuzzel"
            "$mainMod SHIFT, F, exec, zen-beta --profile ~/.config/zen/default/"

            #cliphist
            "$mainMod, V, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"

            # Screenshots
            ", Print, exec, ~/.local/bin/screenshot.sh area"
            "$mainMod, Print, exec, ~/.local/bin/screenshot.sh screen"
            "$mainMod SHIFT, Print, exec, ~/.local/bin/screenshot.sh window"

            # Wallpaper picker
            "$mainMod, W, exec, foot --app-id wallpaper-picker -e ~/.local/bin/pick-wallpaper.sh"

            # Script launcher
            "$mainMod, E, exec, foot --app-id script-launcher -e ~/.local/bin/script-launcher.sh"

            # Lock
            "$mainMod SHIFT, L, exec, loginctl lock-session"

            # Focus movement (arrows)
            "$mainMod, left, movefocus, l"
            "$mainMod, right, movefocus, r"
            "$mainMod, up, movefocus, u"
            "$mainMod, down, movefocus, d"

            # Focus movement (vim keys)
            "$mainMod, h, movefocus, l"
            "$mainMod, l, movefocus, r"
            "$mainMod, k, movefocus, u"
            "$mainMod, j, movefocus, d"

            # super + R, arrow keys resize
            "$mainMod CTRL, R, submap, resize"

            # Special workspaces
            "$mainMod, S, togglespecialworkspace, magic"
            "$mainMod, D, exec, pgrep electron && hyprctl dispatch togglespecialworkspace discord || electron &"
            "$mainMod, P, exec, hyprctl dispatch togglespecialworkspace spotify"
            "$mainMod, O, exec, hyprctl dispatch togglespecialworkspace obsidian"

            "$mainMod SHIFT, S, movetoworkspace, special:magic"

            # Workspace switching
            "$mainMod, 1, workspace, 1"
            "$mainMod, 2, workspace, 2"
            "$mainMod, 3, workspace, 3"
            "$mainMod, 4, workspace, 4"
            "$mainMod, 5, workspace, 5"
            "$mainMod, 6, workspace, 6"
            "$mainMod, 7, workspace, 7"
            "$mainMod, 8, workspace, 8"
            "$mainMod, 9, workspace, 9"
            "$mainMod, 0, workspace, 10"

            # Move window to workspace
            "$mainMod SHIFT, 1, movetoworkspace, 1"
            "$mainMod SHIFT, 2, movetoworkspace, 2"
            "$mainMod SHIFT, 3, movetoworkspace, 3"
            "$mainMod SHIFT, 4, movetoworkspace, 4"
            "$mainMod SHIFT, 5, movetoworkspace, 5"
            "$mainMod SHIFT, 6, movetoworkspace, 6"
            "$mainMod SHIFT, 7, movetoworkspace, 7"
            "$mainMod SHIFT, 8, movetoworkspace, 8"
            "$mainMod SHIFT, 9, movetoworkspace, 9"
            "$mainMod SHIFT, 0, movetoworkspace, 10"
        ];

        bindm = [
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
        ];

        # Media keys (no mod required)
        bindl = [
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPrev, exec, playerctl previous"
            ", XF86AudioMute, exec, pamixer -t"
        ];
        bindle = [
            ", XF86AudioRaiseVolume, exec, pamixer -i 5"
            ", XF86AudioLowerVolume, exec, pamixer -d 5"
            ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
            ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ];

        # Resize submap
        submap = "reset";

        # Resize submap block (must be raw text after settings)
    };
    wayland.windowManager.hyprland.extraConfig = ''
        # --- Resize submap ---
        submap = resize

        binde = , H, resizeactive, -20 0
        binde = , J, resizeactive, 0 20
        binde = , K, resizeactive, 0 -20
        binde = , L, resizeactive, 20 0

        binde = , left,  resizeactive, -20 0
        binde = , down,  resizeactive, 0 20
        binde = , up,    resizeactive, 0 -20
        binde = , right, resizeactive, 20 0

        # exit resize mode
        bind = , Escape, submap, reset
        bind = , Return, submap, reset

        # safety: any other key exits resize mode
        bind = , catchall, submap, reset

        submap = reset
    '';
}
