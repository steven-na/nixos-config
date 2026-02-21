{
    imports = [
        ./btop.nix
        ./extras.nix
    ];

    programs.fish = {
        enable = true;
        interactiveShellInit = ''
            set fish_greeting # Disable greeting
            # Restore wallust colors for shell env on new sessions
            if test -f ~/.cache/wallust/colors.fish
              source ~/.cache/wallust/colors.fish
            end

            # Add local scripts to PATH
            fish_add_path ~/.local/bin
        '';
        shellAliases = {
            ls = "eza --icons --group-directories-first";
            ll = "eza -la --icons --group-directories-first";
            lt = "eza --tree --icons --level=2";
            cat = "bat";
            cd = "z"; # zoxide
            grep = "rg";
            find = "fd";
            zen = "zen-beta --profile ~/.config/zen/default/";
        };
    };

    programs.starship = {
        enable = true;
        enableFishIntegration = true;
        settings = {
            add_newline = false;
            format = "$directory$git_branch$git_status$character";
            character = {
                success_symbol = "[❯](bold green)";
                error_symbol = "[❯](bold red)";
                vicmd_symbol = "[❮](bold blue)";
            };
            directory = {
                truncation_length = 3;
                truncate_to_repo = true;
                style = "bold cyan";
            };
            git_branch = {
                symbol = " ";
                style = "bold purple";
            };
            git_status = {
                style = "bold yellow";
            };
        };
    };

    programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
    };

    programs.fzf = {
        enable = true;
        enableFishIntegration = true;
        # Style fzf with wallust colors at runtime via env vars
        # These get set when wallust generates a colors.fish/colors.sh
        defaultOptions = [
            "--height 40%"
            "--border"
            "--layout=reverse"
            "--info=inline"
        ];
    };

    programs.eza.enable = true;
    programs.bat = {
        enable = true;
        config.theme = "ansi"; # uses terminal colors = wallust colors
    };

    programs.zsh = {
        enable = true; # Keep as fallback shell
    };

    programs.direnv = {
        enable = true;
        enableFishIntegration = true;
        nix-direnv.enable = true; # caches shells so reloads are instant
    };

    programs.yazi = {
        enable = true;
        shellWrapperName = "y";
        settings = {
            mgr = {
                show_hidden = true;
                sort_dir_first = true;
            };
        };
    };
}
