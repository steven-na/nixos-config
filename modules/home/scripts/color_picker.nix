{ pkgs, ... }:

{
    scriptLauncher.scripts = [
        {
            icon = "󰈊";
            label = "Color Picker";
            script = "color-picker.sh";
        }
    ];

    home.file.".local/bin/color-picker.sh" = {
        force = true;
        executable = true;
        text = # bash
            ''
                #!/usr/bin/env bash
                set -eu

                color="$(
                  ${pkgs.hyprpicker}/bin/hyprpicker --autocopy --no-fancy
                )"

                [ -n "$color" ] || exit 0

                printf '%s' "$color" | ${pkgs.wl-clipboard}/bin/wl-copy
                ${pkgs.libnotify}/bin/notify-send "Color picked" "$color"
            '';
    };

    home.packages = with pkgs; [
        hyprpicker
    ];
}
