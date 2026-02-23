{ pkgs, ... }:

{
    scriptLauncher.scripts = [
        {
            icon = "⏻";
            label = "Power Menu";
            script = "power-menu.sh";
        }
    ];

    home.file.".local/bin/power-menu.sh" = {
        force = true;
        executable = true;
        text = # bash
            ''
                #!/usr/bin/env bash
                set -eu

                options="Shutdown\nReboot\nSuspend\nHibernate\nLogout"

                selection="$(
                  printf '%b' "$options" |
                    ${pkgs.fzf}/bin/fzf \
                      --prompt='> ' \
                      --height=100% \
                      --layout=reverse \
                      --no-border \
                      --no-info
                )"

                [ -n "$selection" ] || exit 0

                case "$selection" in
                  Shutdown)  systemctl poweroff ;;
                  Reboot)    systemctl reboot ;;
                  Suspend)   systemctl suspend ;;
                  Hibernate) systemctl hibernate ;;
                  Logout)    hyprctl dispatch exit ;;
                esac
            '';
    };
}
