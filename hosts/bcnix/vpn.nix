{ config, pkgs, ... }:
let
    iface = "wg0";
    user = "blakec";
in
{
    systemd.services."wg-${iface}-user" = {
        description = "WireGuard ${iface} – user controlled";
        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "systemctl start wireguard-${iface}";
            ExecStop = "systemctl stop wireguard-${iface}";
            User = "root";
        };
        wantedBy = [ "multi-user.target" ];
    };

    security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              action.lookup("unit") == "wg-${iface}-user.service" &&
              subject.user == "${user}") {
            return polkit.Result.YES;
          }
        });
    '';

    networking.wireguard.interfaces.wg0 = {
        ips = [ "192.168.99.2/24" ];
        privateKeyFile = "/home/blakec/secrets/wg/privatekey";

        peers = [
            {
                publicKey = "42IJZ5uAzGCLWTeR6RUS0KeVCuDMF3WnP6g8DaSkAHo=";
                allowedIPs = [
                    "192.168.99.0/24"
                    "192.168.10.0/24"
                ];
                endpoint = "vpn.stvnc.dev:51820";
                persistentKeepalive = 25;
            }
        ];
    };
}
