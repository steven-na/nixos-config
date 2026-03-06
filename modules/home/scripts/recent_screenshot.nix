{ pkgs, ... }:

{
    scriptLauncher.scripts = [
        {
            icon = "󱛟";
            label = "Recent Screenshots";
            script = "recent-screenshots.sh";
        }
    ];

    home.file.".local/bin/recent-screenshots.sh" = {
        force = true;
        executable = true;
        text = # bash
            ''
                #!/usr/bin/env bash
                set -eu

                SAVE_DIR="$HOME/Pictures/Screenshots"

                files="$(
                  ${pkgs.findutils}/bin/find "$SAVE_DIR" -maxdepth 1 -type f -iname '*.png' \
                    -printf '%T@ %P\n' |
                    sort -rn |
                    ${pkgs.gawk}/bin/awk '{print $2}'
                )"

                selection="$(ags request "pick-image:$(
                  echo "$files" | ${pkgs.gnused}/bin/sed "s|^|''${SAVE_DIR}/|"
                )")"

                [ -n "$selection" ] || exit 0

                ${pkgs.wl-clipboard}/bin/wl-copy < "$selection"
                ${pkgs.libnotify}/bin/notify-send "Screenshot copied" "$(basename "$selection")"
            '';
    };

    home.packages = with pkgs; [
        findutils
    ];
}
