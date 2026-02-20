{ ... }:
{
    wayland.windowManager.hyprland.settings = {
        general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 2;

            "col.active_border" = "rgba(cdd6f4ff)";
            "col.inactive_border" = "rgba(595959aa)";
        };

        decoration = {
            rounding = 8;
            blur = {
                enabled = true;
                xray = false;
                special = true;
                new_optimizations = true;
                size = 6;
                passes = 3;
                vibrancy = 0.2;
                popups = true;
                popups_ignorealpha = 0.6;
            };
            active_opacity = 1.0;
            inactive_opacity = 0.92;
        };

        animations = {
            enabled = true;
            # smooth i3-like feel, not over the top
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
                "windows, 1, 4, myBezier"
                "windowsOut, 1, 4, default, popin 80%"
                "fade, 1, 4, default"
                "workspaces, 1, 4, default"
            ];
        };
    };
}
