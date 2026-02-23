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

                selection="$(
                  ${pkgs.findutils}/bin/find "$SAVE_DIR" -maxdepth 1 -type f -iname '*.png' \
                    -printf '%T@ %P\n' |
                    sort -rn |
                    ${pkgs.gawk}/bin/awk '{print $2}' |
                    ${pkgs.fzf}/bin/fzf \
                      --prompt='> ' \
                      --height=100% \
                      --layout=reverse \
                      --no-border \
                      --no-info \
                      --preview="${pkgs.chafa}/bin/chafa -f sixel -s \"\$FZF_PREVIEW_COLUMNS\"x\"\$FZF_PREVIEW_LINES\" --animate off -- '$SAVE_DIR/{}'" \
                      --preview-window='right,60%'
                )"

                [ -n "$selection" ] || exit 0

                ${pkgs.wl-clipboard}/bin/wl-copy < "$SAVE_DIR/$selection"
                ${pkgs.libnotify}/bin/notify-send "Screenshot copied" "$selection"
            '';
    };

    home.packages = with pkgs; [
        fzf
        chafa
        findutils
    ];
}
