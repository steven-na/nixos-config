{
    pkgs,
    inputs,
    ...
}:
{
    imports = [
        inputs.zen-browser.homeModules.beta
    ];
    programs.zen-browser = {
        enable = true;
        suppressXdgMigrationWarning = true;
        profiles.default =
            let
                containers = {
                    Normal = {
                        color = "toolbar";
                        id = 1;
                    };
                };
                spaces = {
                    "Normal" = {
                        id = "1f0ad8dc-1029-4f10-89f1-97f4bd5969a2";
                        position = 1000;
                        container = containers.Normal.id;
                    };
                };
                pins = {
                    "YouTube" = {
                        id = "702d57fb-a534-4955-b8be-872c86ca1936";
                        workspace = spaces.Normal.id;
                        url = "https://youtube.com";
                        isEssential = true;
                        position = 101;
                    };
                    "Github" = {
                        id = "55a85043-988b-4448-a66e-7c54e65b83c5";
                        workspace = spaces.Normal.id;
                        url = "https://github.com/";
                        isEssential = true;
                        position = 102;
                    };
                    "ChatGPT" = {
                        id = "bfd1d05a-71f6-4e1e-a337-35ab51ffac8b";
                        workspace = spaces.Normal.id;
                        url = "https://chatgpt.com/";
                        isEssential = true;
                        position = 103;
                    };
                    "T3 Chat" = {
                        id = "60b7e910-8194-4e42-b2d6-51ff4d34b802";
                        workspace = spaces.Normal.id;
                        url = "https://t3.chat/";
                        isEssential = true;
                        position = 104;
                    };
                    "NixOS" = {
                        id = "b5ee1a33-b2ef-4034-9a28-9a7fccbb8b9d";
                        workspace = spaces.Normal.id;
                        isGroup = true;
                        isFolderCollapsed = false;
                        editedTitle = true;
                        position = 200;
                    };
                    "Nix Packages" = {
                        id = "26381d36-e7b9-47d5-a7d7-fb8f3e7eac17";
                        workspace = spaces.Normal.id;
                        folderParentId = pins."NixOS".id;
                        url = "https://search.nixos.org/packages";
                        position = 201;
                    };
                    "Nix Options" = {
                        id = "92931d60-fd40-4707-9512-a57b1a6a3919";
                        workspace = spaces.Normal.id;
                        folderParentId = pins."NixOS".id;
                        url = "https://search.nixos.org/options";
                        position = 202;
                    };
                    "Home Manager Options" = {
                        id = "2eed5614-3896-41a1-9d0a-a3283985359b";
                        workspace = spaces.Normal.id;
                        folderParentId = pins."NixOS".id;
                        url = "https://home-manager-options.extranix.com";
                        position = 203;
                    };
                };
            in
            {
                pinsForce = true;
                containersForce = true;
                spacesForce = true;
                inherit containers pins spaces;
                id = 0;
                # sine.enable = true;
                keyboardShortcuts = [
                    {
                        id = "key_selectTab1";
                        key = "1";
                        modifiers.control = true;
                    }
                    {
                        id = "key_selectTab2";
                        key = "2";
                        modifiers.control = true;
                    }
                    {
                        id = "key_selectTab3";
                        key = "3";
                        modifiers.control = true;
                    }
                    {
                        id = "key_selectTab4";
                        key = "4";
                        modifiers.control = true;
                    }
                    {
                        id = "key_selectTab5";
                        key = "5";
                        modifiers.control = true;
                    }
                    {
                        id = "key_selectTab6";
                        key = "6";
                        modifiers.control = true;
                    }
                    {
                        id = "key_selectTab7";
                        key = "7";
                        modifiers.control = true;
                    }
                    {
                        id = "key_selectTab8";
                        key = "8";
                        modifiers.control = true;
                    }
                    {
                        id = "key_selectLastTab";
                        key = "9";
                        modifiers.control = true;
                    }
                ];
                extensions.packages =
                    let
                        addons = pkgs.nur.repos.rycee.firefox-addons;
                    in
                    [
                        addons.ublock-origin
                        addons.proton-pass
                        addons.enhancer-for-youtube
                        addons.darkreader
                        addons.sponsorblock
                        addons.dearrow
                        addons.zen-internet
                    ];
                # extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
                #     ublock-origin
                #     proton-pass
                #     enhancer-for-youtube
                #     # zen-internet
                #     darkreader
                #     sponsorblock
                #     dearrow
                # ];
                mods = [
                    # Doesn't work with nebula
                    "0c3d77bf-44fc-47a6-a183-39205dfa5f7e"
                    "a6335949-4465-4b71-926c-4a52d34bc9c0"
                    "642854b5-88b4-4c40-b256-e035532109df"
                    "c01d3e22-1cee-45c1-a25e-53c0f180eea8"
                    "ad97bb70-0066-4e42-9b5f-173a5e42c6fc"
                    "6f11c932-b992-433e-8c80-56a613cc511e"
                    "e74cb40a-f3b8-445a-9826-1b1b6e41b846"
                    "253a3a74-0cc4-47b7-8b82-996a64f030d5"
                    "1e86cf37-a127-4f24-b919-d265b5ce29a0"
                    "81fcd6b3-f014-4796-988f-6c3cb3874db8"
                ];
                userChrome = ''
                    /* Auto-theming via wallust — do not edit colors here directly */
                    @import url("file:///home/blakec/.cache/wallust/zen-colors.css");

                    /* Apply variables from wallust to Zen UI */
                    :root {
                      --zen-primary-color: var(--zen-primary-color, #cba6f7) !important;
                    }

                    /* Transparent/blurred tab bar — i3 vibes */
                    #TabsToolbar {
                      background-color: color-mix(
                        in srgb,
                        var(--toolbar-bgcolor) 85%,
                        transparent
                      ) !important;
                      backdrop-filter: blur(12px) !important;
                    }

                    /* Transparent toolbar */
                    #nav-bar {
                      background-color: color-mix(
                        in srgb,
                        var(--toolbar-bgcolor) 80%,
                        transparent
                      ) !important;
                      backdrop-filter: blur(12px) !important;
                    }
                '';
                search = {
                    force = true;
                    default = "ddg";
                    engines = {
                        youtube = {
                            name = "YouTube";
                            urls = [
                                {
                                    template = "https://youtube.com/results?search_query={searchTerms}";
                                    params = [
                                        {
                                            name = "query";
                                            value = "searchTerms";
                                        }
                                    ];
                                }
                            ];
                            definedAliases = [ "@yt" ];
                        };
                        mynixos = {
                            name = "My NixOS";
                            urls = [
                                {
                                    template = "https://mynixos.com/search?q={searchTerms}";
                                    params = [
                                        {
                                            name = "query";
                                            value = "searchTerms";
                                        }
                                    ];
                                }
                            ];
                            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                            definedAliases = [ "@nx" ]; # Keep in mind that aliases defined here only work if they start with "@"
                        };
                    };
                };
                settings = {
                    # Simple Config
                    "browser.aboutConfig.showWarning" = false;
                    "browser.tabs.warnOnClose" = false;
                    "browser.tabs.selectOwnerOnClose" = false;
                    "media.videocontrols.picture-in-picture.video-toggle.enabled" = true;
                    "browser.tabs.hoverPreview.enabled" = true;
                    "browser.tabs.groups.hoverPreview.enabled" = true;
                    "browser.newtabpage.activity-stream.feeds.topsites" = false;
                    "browser.topsites.contile.enabled" = false;
                    "widget.use-xdg-desktop-portal.file-picker" = 1;
                    "zen.welcome-screen.seen" = true;

                    # Transparency
                    "browser.tabs.allow_transparent_browser" = true;
                    "zen.theme.gradient.show-custom-colors" = true;
                    "widget.transparent-windows" = true;
                    "zen.widget.linux.transparency" = true;

                    # Font
                    "font.name.serif.x-western" = "JetBrainsMono Nerd Font";
                    "font.name.sans-serif.x-western" = "JetBrainsMono Nerd Font";
                    "font.name.monospace.x-western" = "JetBrainsMono Nerd Font";

                    # Resist fingerprint (commented below because it breaks dark mode, if you know a fix please tell me)
                    # "privacy.resistFingerprinting" = true;
                    "privacy.resistFingerprinting.randomization.canvas.use_siphash" = true;
                    "privacy.resistFingerprinting.randomization.daily_reset.enabled" = true;
                    "privacy.resistFingerprinting.randomization.daily_reset.private.enabled" = true;
                    "privacy.resistFingerprinting.block_mozAddonManager" = true;
                    "privacy.spoof_english" = 1;

                    # Misc
                    "privacy.firstparty.isolate" = true;
                    "network.cookie.cookieBehavior" = 5;
                    "dom.battery.enabled" = false;

                    "gfx.webrender.all" = true;
                    "network.http.http3.enabled" = true;
                    "network.socket.ip_addr_any.disabled" = true; # disallow bind to 0.0.0.0
                };
            };
        policies = {
            AutofillAddressEnabled = true;
            AutofillCreditCardEnabled = false;
            DisableAppUpdate = true;
            DisableFeedbackCommands = true;
            DisableFirefoxStudies = true;
            DisablePocket = true;
            DisableTelemetry = true;
            DontCheckDefaultBrowser = true;
            NoDefaultBookmarks = true;
            OfferToSaveLogins = false;
            EnableTrackingProtection = {
                Value = true;
                Locked = true;
                Cryptomining = true;
                Fingerprinting = true;
            };
            SanitizeOnShutdown = {
                FormData = true;
                Cache = true;
            };
        };
    };

    xdg.mimeApps =
        let
            value =
                let
                    zen-browser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta;
                in
                zen-browser.meta.desktopFileName;

            associations = builtins.listToAttrs (
                map
                    (name: {
                        inherit name value;
                    })
                    [
                        "application/x-extension-shtml"
                        "application/x-extension-xhtml"
                        "application/x-extension-html"
                        "application/x-extension-xht"
                        "application/x-extension-htm"
                        "x-scheme-handler/unknown"
                        "x-scheme-handler/mailto"
                        "x-scheme-handler/chrome"
                        "x-scheme-handler/about"
                        "x-scheme-handler/https"
                        "x-scheme-handler/http"
                        "application/xhtml+xml"
                        "application/json"
                        "text/plain"
                        "text/html"
                    ]
            );
        in
        {
            associations.added = associations;
            defaultApplications = associations;
        };
}
