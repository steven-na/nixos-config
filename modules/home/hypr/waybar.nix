{
    programs.waybar = {
        enable = true;
        settings = [
            {
                layer = "top";
                position = "top";
                height = 32;
                modules-left = [
                    "hyprland/workspaces"
                    "hyprland/window"
                ];
                modules-center = [ "clock" ];
                modules-right = [
                    "pulseaudio"
                    "network"
                    "battery" # remove if desktop
                    "tray"
                    "custom/wallpaper"
                ];

                "hyprland/workspaces".format = "{id}";
                "clock".format = "{:%a %b %d  %H:%M}";
                "pulseaudio" = {
                    format = " {volume}%";
                    on-click = "pavucontrol";
                };
                "custom/wallpaper" = {
                    format = " ";
                    on-click = "foot --app-id wallpaper-picker -e ~/.local/bin/pick-wallpaper.sh";
                    tooltip = false;
                };
            }
        ];

        # Wallust generates ~/.config/waybar/colors.css
        # Base style imports it
        style = ''
            @import "colors.css";

            * {
              font-family: "JetBrainsMono Nerd Font";
              font-size: 13px;
            }

            window#waybar {
              background-color: alpha(@background, 0.85);
              color: @foreground;
              border-bottom: 2px solid @color1;
            }

            #workspaces button {
              color: @foreground;
              background: transparent;
              padding: 0 8px;
            }
            #workspaces button.active {
              color: @color2;
              border-bottom: 2px solid @color2;
            }
            /* ... etc */
        '';
    };

    # wallust template for waybar colors
    xdg.configFile."wallust/templates/waybar.css".text = ''
        @define-color background {{background}};
        @define-color foreground {{foreground}};
        @define-color color0  {{color0}};
        @define-color color1  {{color1}};
        @define-color color2  {{color2}};
        /* ... */
    '';
}
