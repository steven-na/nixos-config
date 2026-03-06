{
    pkgs,
    lib,
    config,
    ...
}:

let
    scriptModules = [
        # Ordered in reverse in picker
        ./doc_browser.nix
        ./screenshot.nix
        ./wallpaper_picker.nix
        ./recent_screenshot.nix
        ./color_picker.nix
        ./service_manager.nix
        ./kill_process.nix
        ./set_reminder.nix
        ./power_menu.nix
        ./toggle_vpn.nix
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

                    selection="$(ags request "pick:''${menu}")"

                    [ -n "$selection" ] || exit 0

                    label="$(printf '%s' "$selection" | ${pkgs.gnused}/bin/sed 's/^[^ ]* *//')"

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
            jq
        ];
    };
}
