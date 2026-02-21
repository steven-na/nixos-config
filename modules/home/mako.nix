{ ... }:
{
    services.mako = {
        enable = true;
        settings = {
            font = "JetBrainsMono Nerd Font 12";
            width = 360;
            height = 120;
            padding = "12,16";
            "border-radius" = 8;
            "border-size" = 2;
            "default-timeout" = 5000;
            "max-icon-size" = 48;
            sort = "-time";
            layer = "overlay";
            anchor = "top-right";
            margin = "8";

            # Colors set at runtime by wallust via makoctl reload
            include = "~/.cache/wallust/mako-colors";

            "urgency=low" = {
                "border-color" = "#a6e3a1ff";
                "default-timeout" = 3000;
            };

            "urgency=high" = {
                "border-color" = "#f38ba8ff";
                "background-color" = "#313244cc";
                "default-timeout" = 0;
            };

            "app-name=Wallpaper" = {
                "default-timeout" = 2000;
                "group-by" = "app-name";
            };
        };
    };
}
