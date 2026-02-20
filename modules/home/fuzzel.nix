{ pkgs, ... }:
{
    home.packages = [ pkgs.fuzzel ];

    xdg.configFile."fuzzel/fuzzel.ini".text = ''
        [main]
        font=JetBrainsMono Nerd Font:size=12
        icon-theme=Papirus-Dark
        icons-enabled=yes
        terminal=foot
        width=35
        lines=10
        prompt=❯ 
        fuzzy=yes
        anchor=center
        layer=overlay

        [border]
        width=2
        radius=8

        [dmenu]
        # Enables use as a dmenu replacement for scripts
        # Usage: echo -e "a\nb\nc" | fuzzel --dmenu
        exit-immediately-if-empty=yes

        # Colors injected at runtime by wallust
        [include]
        path=${
            # This is evaluated at build time — wallust generates at runtime.
            # We use a stable path that wallust renders to.
            "~/.cache/wallust/fuzzel-colors.ini"
        }
    '';
}
