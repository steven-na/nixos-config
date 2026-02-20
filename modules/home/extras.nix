{ pkgs, ... }:
{
    home.packages = with pkgs; [
        # Hyprland ecosystem
        hyprpaper # wallpaper daemon
        hypridle # idle/lock daemon
        hyprlock # screen locker (themed via wallust)
        hyprpolkitagent # auth agent (replaces polkit-kde-agent)
        hyprpicker # color picker

        # Clipboard
        wl-clipboard # wl-copy / wl-paste
        cliphist # clipboard history (pipe to fuzzel)

        # Screenshot
        grim # screenshot
        slurp # region selector

        # Audio
        pavucontrol
        playerctl # media key control

        # Theming
        papirus-icon-theme
        nwg-look # GTK theme configurator for Wayland

        # Utilities
        brightnessctl # backlight (laptop)
        libnotify # notify-send
    ];

    services.cliphist.enable = true;
    services.mpd-mpris.enable = true;
}
