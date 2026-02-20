{ ... }:
{
    wayland.windowManager.hyprland.extraConfig = # hyprlang
        ''
             # Discord -> special:discord
             windowrule {
                 name = discord
                 match:class = discord
                 
                 workspace = special:discord silent
             }  

             # Obsidian -> special:obsidian
             windowrule {
                 name = obsidian
                 match:class = obsidian

                 workspace = special:obsidian silent
             }

             # Spotify -> special:spotify
             windowrule {
                 name = spotify
                 match:class = (spotify)
                 workspace = special:spotify silent
                 tile = true
             }

             # Steam friends/settings -> float
             windowrule {
                 name = steam-friends
                 match:class = (steam)
                 match:initial_title = (Friends List)
                 float = true
             }

             windowrule {
                 name = steam-settings
                 match:class = (steam)
                 match:initial_title = (Steam Settings)
                 float = true
             }

             # Zen PiP -> float + pin + opacity
             windowrule {
                 name = zen-pip
                 match:class = (zen)
                 match:initial_title = (Picture-in-Picture)
                 float = true
                 pin = true
                 opacity = 0.0 0.0
             }

             windowrule {
                name = wallpaper-picker
                match:class = (wallpaper-picker)
                center = true
                float = true
                size = 900 600
            }
        '';
}
