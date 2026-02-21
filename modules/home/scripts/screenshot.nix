{ pkgs, ... }:

{
    home.file.".local/bin/screenshot.sh" = {
        executable = true;
        text = ''
            #!/usr/bin/env bash

            MODE="$1"
            SAVE_DIR="$HOME/Pictures/Screenshots"
            mkdir -p "$SAVE_DIR"
            TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
            FILE="$SAVE_DIR/screenshot_$TIMESTAMP.png"

            case "$MODE" in
              area)
                ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$FILE"
                ;;
              screen)
                ${pkgs.grim}/bin/grim "$FILE"
                ;;
              window)
                FOCUSED=$(${pkgs.hyprland}/bin/hyprctl activewindow -j \
                  | ${pkgs.jq}/bin/jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
                ${pkgs.grim}/bin/grim -g "$FOCUSED" "$FILE"
                ;;
              *)
                echo "Usage: $0 {area|screen|window}"
                exit 1
                ;;
            esac

            if [ $? -eq 0 ]; then
              ${pkgs.wl-clipboard}/bin/wl-copy < "$FILE"
              ${pkgs.libnotify}/bin/notify-send "Screenshot saved" "$FILE"
            fi
        '';
    };

    home.packages = with pkgs; [
        grim
        slurp
        jq
        wl-clipboard
        libnotify
    ];
}
