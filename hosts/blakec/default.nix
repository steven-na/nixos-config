{ inputs, pkgs, ... }:
{
    imports = [
        ./hardware-configuration.nix
        ../../modules/system/hyprland.nix
        ../../modules/system/fonts.nix
        ../../modules/system/locale.nix
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "bcnix";
    networking.networkmanager.enable = true;

    users.users.blakec = {
        isNormalUser = true;
        extraGroups = [
            "wheel"
            "networkmanager"
            "audio"
            "video"
        ];
        shell = pkgs.fish;
    };

    nixpkgs.config.allowUnfree = true;

    nix.settings = {
        experimental-features = [
            "nix-command"
            "flakes"
        ];
        auto-optimise-store = true;
    };

    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
    };

    system.stateVersion = "25.05";
}
