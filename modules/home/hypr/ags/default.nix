{ inputs, pkgs, ... }:
{
    # add the home manager module
    imports = [ inputs.ags.homeManagerModules.default ];

    programs.ags = {
        enable = true;

        # symlink to ~/.config/ags
        configDir = ./config;

        # additional packages and executables to add to gjs's runtime
        extraPackages = with pkgs; [
            inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.battery
            inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
            inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.network
            inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.notifd
            inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.mpris
            inputs.astal.packages.${pkgs.stdenv.hostPlatform.system}.tray
            upower
            fzf
            glib-networking
        ];
    };
}
