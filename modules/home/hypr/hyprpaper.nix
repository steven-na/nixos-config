{ ... }:
{
    services.hyprpaper = {
        enable = true;
        settings = {
            splash = false;
            ipc = "on"; # required so set-wallpaper.sh can hot-swap via hyprctl
            preload = [ "~/wallpapers/default.jpg" ];
            wallpaper = [ ",~/wallpapers/default.jpg" ];
        };
    };
}
