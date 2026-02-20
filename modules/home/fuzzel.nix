{ pkgs, ... }:
{
    home.packages = [ pkgs.fuzzel ];

    # wallust template for fuzzel
    xdg.configFile."wallust/templates/fuzzel.ini".text = ''
        [colors]
        background={{background | strip_hash}}cc
        text={{foreground | strip_hash}}ff
        match={{color2 | strip_hash}}ff
        selection={{color1 | strip_hash}}cc
        selection-text={{background | strip_hash}}ff
        border={{color1 | strip_hash}}ff
    '';

    xdg.configFile."fuzzel/fuzzel.ini".text = ''
        [main]
        font=JetBrainsMono Nerd Font:size=12
        icon-theme=Papirus-Dark
        terminal=foot
        width=35
        lines=10
        prompt=❯ 
        fuzzy=yes

        [border]
        width=2
        radius=8

        @include ~/.cache/wallust/fuzzel.ini
    '';
}
