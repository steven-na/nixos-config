{ pkgs, config, ... }:
{
    programs.hyprland = {
        enable = true;
        withUWSM = false; # set true if you want UWSM session management
        xwayland.enable = true;
    };

    # XDG portals — required for screen sharing, file pickers, etc.
    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        # xdg-desktop-portal-hyprland is added automatically by programs.hyprland
    };

    hardware = {
        graphics.enable = true;
        nvidia = {
            modesetting.enable = true;
            powerManagement.enable = false;
            powerManagement.finegrained = false;
            open = false;
            nvidiaSettings = true;
        };
    };

    # PAM for hyprlock authentication
    security.pam.services.hyprlock = { };

    # Audio
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
    };
    security.rtkit.enable = true;

    # Polkit — needed for privilege escalation dialogs
    security.polkit.enable = true;

    # D-Bus
    services.dbus.enable = true;

    services.mpd = {
        enable = true;
        user = "blakec";
        network.listenAddress = "any"; # if you want to allow non-localhost connections
        openFirewall = false;
    };
    systemd.services.mpd.environment = {
        XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.blakec.uid}";
    };
    # Enable Wayland in Electron/Chromium apps
    environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        # Hint to prefer Wayland for specific toolkits
        GDK_BACKEND = "wayland,x11";
        QT_QPA_PLATFORM = "wayland;xcb";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
    };

    # Login manager — greetd with tuigreet is lightweight
    services.greetd = {
        enable = true;
        settings = {
            default_session = {
                command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.hyprland}/bin/start-hyprland";
                user = "blakec";
            };
        };
    };

    environment.systemPackages = with pkgs; [
        tuigreet
        polkit_gnome # polkit auth agent
        xdg-utils
        xdg-user-dirs
    ];
}
