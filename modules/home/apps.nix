{ pkgs, inputs, ... }:
{
    home.packages = with pkgs; [
        # Drafting
        kicad
        freecad-wayland

        # Notes
        obsidian
    ];
}
