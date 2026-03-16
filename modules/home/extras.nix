{ pkgs, config, ... }:
{
    home.packages = with pkgs; [
        # Hyprland ecosystem
        hyprpaper # wallpaper daemon
        hypridle # idle/lock daemon
        hyprlock # screen locker
        hyprpolkitagent # auth agent
        hyprpicker # color picker

        # Clipboard
        wl-clipboard # wl-copy / wl-paste
        cliphist # clipboard history

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
        python315
        upower
    ];

    services.cliphist.enable = true;
    services.mpd-mpris.enable = true;

    services.easyeffects.enable = true;
}
