{ pkgs, ... }:

{
    scriptLauncher.scripts = [
        {
            icon = "󰒔";
            label = "Service Manager";
            script = "service-manager.sh";
        }
    ];

    home.file.".local/bin/service-manager.sh" = {
        force = true;
        executable = true;
        text = # bash
            ''
                #!/usr/bin/env bash
                set -eu

                service="$(
                  systemctl list-units --type=service --all --no-legend --no-pager |
                    ${pkgs.gawk}/bin/awk '{print $1}' |
                    ${pkgs.fzf}/bin/fzf \
                      --prompt='> ' \
                      --height=100% \
                      --layout=reverse \
                      --no-border \
                      --no-info \
                      --preview='systemctl status --no-pager --full {}' \
                      --preview-window='right,60%,wrap'
                )"

                [ -n "$selection" ] || exit 0

                action="$(
                  printf 'status\nstart\nstop\nrestart' |
                    ${pkgs.fzf}/bin/fzf \
                      --prompt='action> ' \
                      --height=100% \
                      --layout=reverse \
                      --no-border \
                      --no-info
                )"

                [ -n "$action" ] || exit 0

                case "$action" in
                  status)  systemctl status --no-pager --full "$service" | ${pkgs.less}/bin/less ;;
                  start)   systemctl start "$service" ;;
                  stop)    systemctl stop "$service" ;;
                  restart) systemctl restart "$service" ;;
                esac

                [ "$action" != "status" ] && \
                  ${pkgs.libnotify}/bin/notify-send "Service $action" "$service"
            '';
    };
}
