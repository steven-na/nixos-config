{ pkgs, inputs, ... }:
{
    home.packages = with pkgs; [
        # Drafting
        kicad
        freecad-wayland
        gimp

        # Notes
        obsidian
    ];
}
