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

    # wallust template → foot colors
    xdg.configFile."wallust/templates/foot-colors.ini".text = ''
        [colors]
        background={{background | strip_hash}}
        foreground={{foreground | strip_hash}}
        regular0={{color0 | strip_hash}}
        regular1={{color1 | strip_hash}}
        # ... all 16 colors
        bright0={{color8 | strip_hash}}
        # ...
    '';

    # foot config includes the generated colors file
    # add to foot settings: include = ~/.cache/wallust/foot-colors.ini
}
