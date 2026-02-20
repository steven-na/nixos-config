{ config, ... }:
let
    wp = "${config.home.homeDirectory}/wallpapers/default.jpg";
in
{
    services.hyprpaper = {
        enable = true;
        settings = {
            ipc = "on";
            splash = false;
            splash_offset = 2;

            preload = [ "~/wallpapers/default.jpg" ];

            wallpaper = [
                "HDMI-A-1,${wp}"
                "eDP-2,${wp}"
            ];
        };
    };
}
