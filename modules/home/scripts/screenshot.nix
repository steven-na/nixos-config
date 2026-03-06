{ pkgs, ... }:

{
    home.file.".local/bin/screenshot.sh" = {
        executable = true;
        text = # bash
            ''
                #!/usr/bin/env bash

                MODE="$1"
                SAVE_DIR="$HOME/Pictures/Screenshots"
                RECORD_DIR="$HOME/Videos/Recordings"
                mkdir -p "$SAVE_DIR" "$RECORD_DIR"
                TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
                FILE="$SAVE_DIR/screenshot_$TIMESTAMP.png"
                RECORD_FILE="$RECORD_DIR/recording_$TIMESTAMP.mp4"

                case "$MODE" in
                    area)
                    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$FILE"
                    if [ $? -eq 0 ]; then
                        ${pkgs.wl-clipboard}/bin/wl-copy < "$FILE"
                        ${pkgs.libnotify}/bin/notify-send "Screenshot saved" "$FILE"
                    fi
                    ;;
                    screen)
                    ${pkgs.grim}/bin/grim "$FILE"
                    if [ $? -eq 0 ]; then
                        ${pkgs.wl-clipboard}/bin/wl-copy < "$FILE"
                        ${pkgs.libnotify}/bin/notify-send "Screenshot saved" "$FILE"
                    fi
                    ;;
                    window)
                    FOCUSED=$(${pkgs.hyprland}/bin/hyprctl activewindow -j \
                        | ${pkgs.jq}/bin/jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
                    ${pkgs.grim}/bin/grim -g "$FOCUSED" "$FILE"
                    if [ $? -eq 0 ]; then
                        ${pkgs.wl-clipboard}/bin/wl-copy < "$FILE"
                        ${pkgs.libnotify}/bin/notify-send "Screenshot saved" "$FILE"
                    fi
                    ;;
                    area-record)
                    AREA=$(${pkgs.slurp}/bin/slurp)
                    if [ -z "$AREA" ]; then
                        exit 1
                    fi
                    AUDIO_SINK=$(${pkgs.pulseaudio}/bin/pactl get-default-sink)
                    ${pkgs.libnotify}/bin/notify-send "Recording started" "Press Super+Alt+Shift+Print to stop"
                    ${pkgs.wf-recorder}/bin/wf-recorder \
                        -g "$AREA" \
                        -f "$RECORD_FILE" \
                        --audio="''${AUDIO_SINK}.monitor" &
                    echo $! > /tmp/wf-recorder.pid
                    ;;
                    area-record-stop)
                    if [ -f /tmp/wf-recorder.pid ]; then
                        kill -SIGINT $(cat /tmp/wf-recorder.pid)
                        rm /tmp/wf-recorder.pid
                        ${pkgs.libnotify}/bin/notify-send "Recording saved" "$RECORD_FILE"
                    else
                        ${pkgs.libnotify}/bin/notify-send "No recording in progress"
                    fi
                    ;;
                    *)
                    echo "Usage: $0 {area|screen|window|area-record|area-record-stop}"
                    exit 1
                    ;;
                esac
            '';
    };

    home.packages = with pkgs; [
        grim
        slurp
        jq
        wl-clipboard
        libnotify
        wf-recorder
        pulseaudio
    ];
}
