let
    enablePrograms =
        names:
        builtins.listToAttrs (
            map (name: {
                inherit name;
                value = {
                    enable = true;
                };
            }) names
        );
in
{
    imports = [
        ./btop.nix
        ./extras.nix
    ];

    programs =
        {
            fish = {
                enable = true;
                interactiveShellInit = ''
                    # Source wallust colors for shell color vars if needed
                    if test -f ~/.cache/wallust/colors.fish
                      source ~/.cache/wallust/colors.fish
                    end
                '';
            };

            starship = {
                enable = true;
                # minimal i3-vibe prompt
                settings = {
                    format = "$directory$git_branch$git_status$character";
                    character = {
                        success_symbol = "[❯](bold green)";
                        error_symbol = "[❯](bold red)";
                    };
                };
            };
        }
        // enablePrograms [
            "zoxide"
            "fzf"
            "eza"
            "bat"
        ];
}
