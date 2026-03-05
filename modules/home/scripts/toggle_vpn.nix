{ pkgs, ... }:

{
    scriptLauncher.scripts = [
        {
            icon = "󱠾";
            label = "Toggle VPN";
            script = "toggle-vpn.sh";
        }
    ];

    home.file.".local/bin/toggle-vpn.sh" = {
        force = true;
        executable = true;
        text = # bash
            ''
                #!/usr/bin/env bash
                set -eu

                if systemctl is-active --quiet wireguard-wg0; then
                    systemctl stop wg-wg0-user
                    exit 0
                else
                    systemctl start wg-wg0-user
                    exit 0
                fi
            '';
    };
}
