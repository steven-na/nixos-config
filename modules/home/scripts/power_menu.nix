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

                options="Shutdown
                         Reboot
                         Suspend
                         Hibernate
                         Logout"

                selection="$(ags request "pick:''${options}")"

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
