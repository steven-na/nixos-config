{ inputs, pkgs, ... }:
{
    imports = [
        ../../modules/home/apps.nix
        ../../modules/home/discord.nix
        ../../modules/home/extras.nix
        ../../modules/home/foot.nix
        ../../modules/home/fuzzel.nix
        ../../modules/home/gtk.nix
        ../../modules/home/hypr
        ../../modules/home/mako.nix
        ../../modules/home/shell/default.nix
        ../../modules/home/spotify.nix
        ../../modules/home/wallust.nix
        ../../modules/home/waybar.nix
        ../../modules/home/zen-browser.nix
        ../../modules/home/git.nix
    ];

    home.username = "blakec";
    home.homeDirectory = "/home/blakec";

    programs.home-manager.enable = true;
    services.ssh-agent.enable = true;

    programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks."*" = {
            serverAliveInterval = 60;
            addKeysToAgent = "yes";
        };
    };

    # Env vars
    home.sessionVariables = {
        EDITOR = "nvim";
        BROWSER = "zen";
        TERMINAL = "foot";
    };

    home.stateVersion = "26.05";
}
