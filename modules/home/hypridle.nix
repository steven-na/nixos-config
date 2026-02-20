{ ... }:
{
    services.hypridle = {
        enable = true;
        settings = {
            general = {
                lock_cmd = "pidof hyprlock || hyprlock";
                before_sleep_cmd = "loginctl lock-session";
                after_sleep_cmd = "hyprctl dispatch dpms on";
                ignore_dbus_inhibit = false;
            };

            listener = [
                # Dim screen after 2.5 min
                {
                    timeout = 150;
                    on-timeout = "brightnessctl -s set 10%";
                    on-resume = "brightnessctl -r";
                }
                # Lock after 5 min
                {
                    timeout = 300;
                    on-timeout = "loginctl lock-session";
                }
                # Screen off after 5m30s
                {
                    timeout = 330;
                    on-timeout = "hyprctl dispatch dpms off";
                    on-resume = "hyprctl dispatch dpms on";
                }
                # Suspend after 30 min
                {
                    timeout = 1800;
                    on-timeout = "systemctl suspend";
                }
            ];
        };
    };
}
