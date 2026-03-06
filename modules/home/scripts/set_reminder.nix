{ pkgs, ... }:

{
    scriptLauncher.scripts = [
        {
            icon = "󰀠";
            label = "Set Reminder";
            script = "set-reminder.sh";
        }
    ];

    home.packages = with pkgs; [
        at
        libnotify
        sox
    ];

    home.file.".local/bin/set-reminder.sh" = {
        force = true;
        executable = true;
        text = # bash
            ''
                #!/usr/bin/env bash
                set -eu

                parse_time() {
                    local input="''${1,,}"

                    if [[ $input =~ ^([0-9]+)(m|min|mins|minute|minutes)$ ]]; then
                        echo "now + ''${BASH_REMATCH[1]} minutes"
                    elif [[ $input =~ ^([0-9]+)(h|hr|hrs|hour|hours)$ ]]; then
                        echo "now + ''${BASH_REMATCH[1]} hours"
                    elif [[ $input =~ ^([0-9]+)(d|day|days)$ ]]; then
                        echo "now + ''${BASH_REMATCH[1]} days"
                    elif [[ $input =~ ^([0-9]+)(w|wk|wks|week|weeks)$ ]]; then
                        echo "now + ''${BASH_REMATCH[1]} weeks"
                    elif [[ $input =~ ^([0-9]+)(mo|month|months)$ ]]; then
                        echo "now + ''${BASH_REMATCH[1]} months"
                    elif [[ $input =~ ^([0-9]+)(y|yr|yrs|year|years)$ ]]; then
                        echo "now + ''${BASH_REMATCH[1]} years"
                    else
                        echo "$input"
                    fi
                }
                echo "=== Set a Reminder ==="
                echo ""
                echo "Examples: 30m, 2h, 1day, 3weeks, 6months, 7:00pm, tomorrow"
                echo -n "When: "
                read -r RAW_TIME

                echo -n "Message: "
                read -r MESSAGE

                AT_TIME=$(parse_time "$RAW_TIME")

                DBUS_ADDR=''${DBUS_SESSION_BUS_ADDRESS:-}
                DISP=''${DISPLAY:-:0}

                echo "DISPLAY=$DISP DBUS_SESSION_BUS_ADDRESS=$DBUS_ADDR notify-send 'Reminder' '$MESSAGE' && play -n synth 0.8 sine 580 sine 880 sine 2000 delay 0 0.01 0.02 remix - fade 0 0.8 0.6 norm -3 gain -15" \
                    | at $AT_TIME

                echo ""
                echo "Reminder set: \"$MESSAGE\" → $AT_TIME"
                echo "Press Enter to close..."
                read -r
            '';
    };
}
