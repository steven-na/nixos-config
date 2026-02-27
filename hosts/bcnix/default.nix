{ pkgs, inputs, ... }:
{
    # boot.kernelPackages = pkgs.linuxPackages_latest;
    imports = [
        ./hardware-configuration.nix
        ../../modules/system/hyprland.nix
        ../../modules/system/fonts.nix
        ../../modules/system/locale.nix
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelModules = [
        "asus-nb-wmi"
        "asus_wmi"
    ];

    networking.hostName = "bcnix";
    networking.networkmanager.enable = true;

    networking.firewall.allowedTCPPorts = [
        22000
    ];
    networking.firewall.allowedUDPPorts = [ 21027 ];

    virtualisation.docker.enable = false;

    services.syncthing = {
        enable = true;
        user = "blakec";
        configDir = "/home/blakec/.config/syncthing";
    };

    services.blueman.enable = true;

    hardware.bluetooth = {
        enable = true;
        settings = {
            General = {
                Experimental = true;
                DisableSecureConnections = true;
                JustWorksRepairing = "always";
            };
        };
    };

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

    programs.fish.enable = true;

    environment.systemPackages = [
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta
    ];

    nixpkgs.config.allowUnfree = true;

    nix.settings = {
        experimental-features = [
            "nix-command"
            "flakes"
        ];
        auto-optimise-store = true;

        substituters = [
            "https://cache.nixos.org"
            "https://hyprland.cachix.org"
            "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeDo="
        ];
    };

    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
    };

    system.stateVersion = "25.05";
}
