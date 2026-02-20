{ ... }:
{
    programs.hyprlock = {
        enable = true;
        settings = {
            general = {
                hide_cursor = true;
                no_fade_in = false;
                disable_loading_bar = true;
                ignore_empty_input = true;
            };

            background = [
                {
                    monitor = "";
                    # hyprlock reads this path at runtime — wallust keeps it updated
                    path = "$HOME/.cache/wallust/last-wallpaper";
                    blur_passes = 3;
                    blur_size = 7;
                    brightness = 0.5;
                }
            ];

            label = [
                # Clock
                {
                    monitor = "";
                    text = ''cmd[update:1000] date +"%-H:%M"'';
                    font_size = 72;
                    font_family = "JetBrainsMono Nerd Font";
                    color = "rgba(cdd6f4ff)";
                    position = "0, 200";
                    halign = "center";
                    valign = "center";
                }
                # Date
                {
                    monitor = "";
                    text = ''cmd[update:60000] date +"%A, %B %d"'';
                    font_size = 18;
                    font_family = "JetBrainsMono Nerd Font";
                    color = "rgba(cdd6f4cc)";
                    position = "0, 120";
                    halign = "center";
                    valign = "center";
                }
            ];

            input-field = [
                {
                    monitor = "";
                    size = "300, 48";
                    outline_thickness = 2;
                    outer_color = "rgba(cdd6f4ff)";
                    inner_color = "rgba(1e1e2ecc)";
                    font_color = "rgba(cdd6f4ff)";
                    fade_on_empty = true;
                    placeholder_text = "󰌾  Password";
                    font_family = "JetBrainsMono Nerd Font";
                    position = "0, -80";
                    halign = "center";
                    valign = "center";
                }
            ];
        };
    };
}
