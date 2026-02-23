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

                selection="$(
                  ${pkgs.procps}/bin/ps -eo pid,user,comm,args --no-headers |
                    ${pkgs.fzf}/bin/fzf \
                      --prompt='> ' \
                      --height=100% \
                      --layout=reverse \
                      --no-border \
                      --no-info \
                      --preview='echo {}' \
                      --preview-window='bottom,3,wrap'
                )"

                [ -n "$selection" ] || exit 0

                pid="$(echo "$selection" | ${pkgs.gawk}/bin/awk '{print $1}')"

                kill "$pid"
                ${pkgs.libnotify}/bin/notify-send "Process killed" "PID $pid"
            '';
    };
}
