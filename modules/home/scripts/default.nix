{
    pkgs,
    lib,
    config,
    ...
}:

let
    scriptModules = [
        ./wallpaper_picker.nix
        ./screenshot.nix
        ./recent_screenshot.nix
        ./power_menu.nix
        ./color_picker.nix
        ./service_manager.nix
        ./kill_process.nix
    ];

    entries = config.scriptLauncher.scripts;

    configFile = pkgs.writeText "launcher-scripts.json" (builtins.toJSON entries);
in
{
    imports = scriptModules;

    options.scriptLauncher.scripts = lib.mkOption {
        type = lib.types.listOf (
            lib.types.submodule {
                options = {
                    icon = lib.mkOption { type = lib.types.str; };
                    label = lib.mkOption { type = lib.types.str; };
                    script = lib.mkOption { type = lib.types.str; };
                };
            }
        );
        default = [ ];
        description = "Scripts to show in the launcher menu.";
    };

    config = {
        home.file.".local/bin/script-launcher.sh" = {
            force = true;
            executable = true;
            text = # bash
                ''
                    #!/usr/bin/env sh
                    set -eu

                    config="${configFile}"

                    menu="$(
                      ${pkgs.jq}/bin/jq -r '.[] | "\(.icon)  \(.label)"' "$config"
                    )"

                    selection="$(
                        printf '%s\n' "$menu" | \
                            ${pkgs.fzf}/bin/fzf \
                            --prompt='Launch> ' \
                            --height=100% \
                            --layout=reverse \
                            --no-border \
                            --no-info
                    )"

                    [ -n "$selection" ] || exit 0

                    label="$(printf '%s' "$selection" | sed 's/^[^ ]* *//')"

                    script="$(
                      ${pkgs.jq}/bin/jq -r \
                        --arg label "$label" \
                        '.[] | select(.label == $label) | .script' \
                        "$config"
                    )"

                    exec "$HOME/.local/bin/$script"
                '';
        };
        home.packages = with pkgs; [
            fzf
            jq
        ];
    };
}
