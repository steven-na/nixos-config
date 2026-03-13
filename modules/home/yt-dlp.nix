# modules/home/yt-dlp.nix
{ pkgs, config, ... }:

{
    programs.yt-dlp = {
        enable = true;
        settings = {
            format = "bestvideo+bestaudio/best";
            merge-output-format = "mkv";
            output = "~/Videos/yt-dlp/%(uploader)s/%(title)s.[%(id)s].%(ext)s";

            # Subtitles
            write-subs = true;
            write-auto-subs = true;
            sub-langs = "en.*,es,fr,de,ja";
            embed-subs = true;

            # Metadata
            embed-thumbnail = true;
            embed-metadata = true;
            embed-chapters = true;

            # Behavior
            no-overwrites = true;
            continue = true;
            ignore-errors = true;
            retries = 10;
            fragment-retries = 10;

            # Rate limiting
            sleep-interval = 1;
            max-sleep-interval = 5;

            # SponsorBlock
            sponsorblock-mark = "all";

            # Archive
            download-archive = "~/.config/yt-dlp/archive.txt";

            # Aria2
            downloader = "aria2c";
            downloader-args = "aria2c:'-c -x 16 -s 16 -k 1M'";

            # Cookies (uncomment as needed)
            # cookies-from-browser = "firefox";
        };
    };

    # Runtime dependencies
    home.packages = with pkgs; [
        ffmpeg-full
        atomicparsley
        aria2
        rtmpdump
    ];

    # Audio-only config
    xdg.configFile."yt-dlp/audio.conf".text = ''
        -f bestaudio/best
        -x
        --audio-format opus
        --audio-quality 0
        --embed-thumbnail
        --embed-metadata
        -o ~/Music/%(uploader)s/%(title)s [%(id)s].%(ext)s
        --download-archive ~/.config/yt-dlp/music-archive.txt
    '';

    # Ensure output directories exist
    xdg.userDirs = {
        enable = true;
        createDirectories = true;
        videos = "${config.home.homeDirectory}/Videos";
        music = "${config.home.homeDirectory}/Music";
    };
}
