{ pkgs, ... }:

{
    scriptLauncher.scripts = [
        {
            icon = "";
            label = "Wallpaper Picker";
            script = "pick-wallpaper.sh";
        }
    ];

    home.file.".local/bin/pick-wallpaper.sh" = {
        force = true;
        executable = true;
        text = # bash
            ''
                #!/usr/bin/env sh
                set -eu

                dir="''${WALLPAPER_DIR:-$HOME/wallpapers}"
                cd "$dir" || exit 1

                selection="$(
                  ${pkgs.findutils}/bin/find . -maxdepth 1 -type f \
                    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) \
                    -printf '%P\n' |
                    ${pkgs.fzf}/bin/fzf --prompt='Wallpaper> ' \
                      --height=100% \
                      --layout=reverse \
                      --no-border \
                      --no-info \
                      --preview-window='right,60%,border-left' \
                      --preview="$HOME/.local/bin/wallpaper-preview.sh '$dir/{}'"
                )"

                [ -n "$selection" ] || exit 0
                exec "$HOME/.local/bin/set-wallpaper.sh" "$dir/$selection"
            '';
    };

    home.file.".local/bin/wallpaper-preview.sh" = {
        force = true;
        executable = true;
        text = # bash
            ''
                #!/usr/bin/env sh
                set -eu

                img="$1"

                cols="''${FZF_PREVIEW_COLUMNS:-80}"
                lines="''${FZF_PREVIEW_LINES:-24}"

                ${pkgs.chafa}/bin/chafa -f sixel -s "''${cols}x''${lines}" --animate off --polite -- "$img" 2>/dev/null \
                  || ${pkgs.chafa}/bin/chafa -s "''${cols}x''${lines}" -- "$img" 2>/dev/null \
                  || printf '%s\n' "No preview (install chafa with sixel support, or install 'file')."
            '';
    };

    home.packages = with pkgs; [
        fzf
        chafa
        findutils
    ];
}
