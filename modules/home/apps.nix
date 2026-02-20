{ pkgs, ... }:
{
    home.packages = with pkgs; [
        # Drafting
        kicad
        freecad-wayland

        # Notes
        obsidian
    ];
}
