{ pkgs, ... }:

{
    scriptLauncher.scripts = [
        {
            icon = "󱄎";
            label = "Kill Process";
            script = "kill-process.sh";
        }
    ];

    home.file.".local/bin/kill-process.sh" = {
        force = true;
        executable = true;
        text = # bash
            ''
                #!/usr/bin/env bash
                set -eu

                SCRIPT="$HOME/.local/bin/kill-process.sh"

                if [ "''${1:-}" != "--inner" ]; then
                  exec foot --app-id float-term -e "$SCRIPT" --inner
                fi

                selection="$(
                  ${pkgs.procps}/bin/ps -eo pid,user,comm,args --no-headers |
                    ${pkgs.fzf}/bin/fzf \
                      --multi \
                      --prompt='> ' \
                      --height=100% \
                      --layout=reverse \
                      --no-border \
                      --no-info \
                      --preview='echo {}' \
                      --preview-window='bottom,3,wrap'
                )"

                [ -n "$selection" ] || exit 0

                killed=""
                while IFS= read -r line; do
                  pid="$(echo "$line" | ${pkgs.gawk}/bin/awk '{print $1}')"
                  kill "$pid" && killed="$killed $pid"
                done <<< "$selection"

                ${pkgs.libnotify}/bin/notify-send "Process(es) killed" "PIDs:$killed"
            '';
    };
}
