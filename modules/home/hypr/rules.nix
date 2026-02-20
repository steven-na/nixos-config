{ ... }:
{
    wayland.windowManager.hyprland.extraConfig = # hyprlang
        ''
            # Bind D = Discord special
            windowrulev2 = tile,class:(discord)
            windowrulev2 = workspace special:discord silent,class:(discord)

            # Bind O = Obsidian special
            windowrulev2 = tile,class:(obsidian)
            windowrulev2 = workspace special:obsidian silent,class:(obsidian)

            # Bind P = Spotify special
            windowrulev2 = tile,class:(spotify)
            windowrulev2 = workspace special:spotify silent,class:(spotify)

            # Force floating window for steam friends
            windowrulev2 = float, class:steam, initialTitle:Friends List
            windowrulev2 = float, class:steam, initialTitle:Steam Settings

            # Picture-in-picture floating and pinned
            windowrulev2 = float, class:zen, initialTitle:"Picture-in-Picture"
            windowrulev2 = pin, class:zen, initialTitle:"Picture-in-Picture"
            windowrulev2 = opacity 0.0, class:zen, initialTitle:"Picture-in-Picture"
        '';
}
