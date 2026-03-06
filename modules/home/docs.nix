{ config, pkgs, ... }:
{
    home.packages = with pkgs; [
        pinfo
        tealdeer
        cheat
        zeal
        nix
        fzf
        man
    ];

    xdg.configFile."tealdeer/config.toml".text = ''
        [display]
        compact = false
        use_pager = false

        [updates]
        auto_update = true
        auto_update_interval_hours = 168
    '';

    xdg.configFile."cheat/conf.yml".text = ''
        ---
        colorize: true
        style: monokai

        cheatpaths:
          - name: community
            path: ${config.home.homeDirectory}/.local/share/cheat/community
            tags: [ community ]
            readonly: true

          - name: personal
            path: ${config.xdg.configHome}/cheat/personal
            tags: [ personal ]
            readonly: false
    '';

    xdg.dataFile."fish/vendor_completions.d/tldr.fish".source =
        "${pkgs.tealdeer}/share/fish/vendor_completions.d/tldr.fish";

    programs.fish = {
        shellAliases = {
            info = "pinfo";
        };

        shellAbbrs = {
            tl = "tldr";
            m1 = "man 1";
            m2 = "man 2";
            m3 = "man 3";
            m5 = "man 5";
            m7 = "man 7";
            m8 = "man 8";
        };

        functions = {
            # fuzzy tldr browser
            tldrf = {
                description = "Fuzzy search tldr pages with preview";
                body = ''
                    tldr --list | fzf \
                      --preview 'tldr --color always {}' \
                      --preview-window=right:70% \
                      | xargs tldr
                '';
            };

            # fuzzy man page search
            fman = {
                description = "Fuzzy search man pages";
                body = ''
                    man -k . 2>/dev/null \
                      | fzf --prompt='Man> ' \
                            --preview 'echo {} | awk "{print \$1}" | xargs -I% man -P cat %' \
                      | awk '{print $1}' \
                      | xargs man
                '';
            };

            # fuzzy cheat browser
            cheatf = {
                description = "Fuzzy cheat search with preview";
                body = ''
                    cheat -l 2>/dev/null \
                      | tail -n +2 \
                      | fzf --preview 'cheat {1}' \
                            --preview-window=right:70% \
                      | awk '{print $1}' \
                      | xargs cheat
                '';
            };
        };
    };

    manual.manpages.enable = true; # generates man home-configuration.nix
}

# Setup:
# tldr --update; mkdir -p ~/.local/share/cheat; git clone https://github.com/cheat/cheatsheets ~/.local/share/cheat/community
