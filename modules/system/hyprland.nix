{
    pkgs,
    ...
}:
{
    programs.hyprland.enable = true;
    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        wireplumber.enable = true;
    };
    security.polkit.enable = true;
    security.rtkit.enable = true; # for pipewire realtime priority
}
