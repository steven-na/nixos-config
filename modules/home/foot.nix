{
    programs.foot = {
        enable = true;
        settings = {
            main = {
                font = "JetBrainsMono Nerd Font:size=12";
                pad = "8x8";
                shell = "fish";
            };
            mouse.hide-when-typing = "yes";
            scrollback.lines = 10000;
            url.launch = "xdg-open \${url}";

            # Colors sourced from wallust at runtime via include
            # foot supports @include directive
        };
    };
    # foot config includes the generated colors file
    # add to foot settings: include = ~/.cache/wallust/foot-colors.ini
}
