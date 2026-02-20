{
    services.mako = {
        enable = true;
        settings = {
            font = "JetBrainsMono Nerd Font 12";
            width = 350;
            height = 110;
            padding = "12";
            border-radius = 8;
            border-size = 2;
            default-timeout = 5000;
            # mako supports include, so wallust generates the color block
        };
    };

    # wallust template for mako
    xdg.configFile."wallust/templates/mako".text = ''
        background-color={{background}}cc
        text-color={{foreground}}ff
        border-color={{color1}}ff
        [urgency=high]
        border-color={{color1}}ff
    '';
}
