{ pkgs, inputs, ... }:
{
    home.packages = with pkgs; [
        # Drafting
        kicad
        freecad-wayland
        gimp
        darktable

        # Notes
        obsidian

        # De-internet
        newsboat
        w3m-full
        vlc
    ];

    systemd.user.services.newsboat-reload = {
        Unit.Description = "Reload newsboat feeds";
        Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.newsboat}/bin/newsboat -x reload";
        };
    };

    systemd.user.timers.newsboat-reload = {
        Unit.Description = "Reload newsboat feeds timer";
        Timer = {
            OnCalendar = "*:0/30";
            Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
    };
}
