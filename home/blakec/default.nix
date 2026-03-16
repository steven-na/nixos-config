{ inputs, pkgs, ... }:
{
    imports = [
        ../../modules/home/apps.nix
        ../../modules/home/discord.nix
        ../../modules/home/docs.nix
        ../../modules/home/extras.nix
        ../../modules/home/foot.nix
        ../../modules/home/git.nix
        ../../modules/home/gtk.nix
        ../../modules/home/hypr
        ../../modules/home/mako.nix
        ../../modules/home/networking.nix
        ../../modules/home/scripts
        ../../modules/home/shell/default.nix
        ../../modules/home/spotify.nix
        ../../modules/home/wallust.nix
        ../../modules/home/yt-dlp.nix
        ../../modules/home/zen-browser.nix
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
        extraConfig = ''
            Host 192.168.10.1
              IgnoreUnknown WarnWeakCrypto
              WarnWeakCrypto no-pq-kex
        '';
    };

    # Env vars
    home.sessionVariables = {
        EDITOR = "nvim";
        BROWSER = "zen-beta";
        TERMINAL = "foot";
    };

    home.stateVersion = "25.05";
}
