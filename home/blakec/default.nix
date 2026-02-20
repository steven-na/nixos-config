{ inputs, pkgs, ... }:
{
    imports = [
        ../../modules/home/hyprland.nix
        ../../modules/home/hyprpaper.nix
        ../../modules/home/hyprlock.nix
        ../../modules/home/hypridle.nix
        ../../modules/home/wallust.nix
        ../../modules/home/waybar.nix
        ../../modules/home/foot.nix
        ../../modules/home/fuzzel.nix
        ../../modules/home/mako.nix
        ../../modules/home/discord.nix
        ../../modules/home/zen-browser.nix
        ../../modules/home/shell.nix
        ../../modules/home/gtk.nix
        ../../modules/home/extras.nix
    ];

    home.username = "blakec";
    home.homeDirectory = "/home/blakec";

    programs.home-manager.enable = true;

    # Env vars
    home.sessionVariables = {
        EDITOR = "nvim"; # or your preferred editor
        BROWSER = "zen";
        TERMINAL = "foot";
    };

    home.stateVersion = "25.05";
}
