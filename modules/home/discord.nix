{
    inputs,
    pkgs,
    ...
}:
{
    imports = [
        inputs.nixcord.homeModules.nixcord
    ];

    home.packages = [
        inputs.themecord.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    programs.nixcord = {
        enable = true;
        discord.vencord.enable = true;
        config = {
            useQuickCss = true;
            transparent = true;
            frameless = true;
            plugins = {
                alwaysAnimate.enable = false;
                alwaysTrust.enable = true;
                betterSettings = {
                    enable = true;
                    disableFade = true;
                    organizeMenu = true;
                    eagerLoad = true;
                };
                biggerStreamPreview.enable = true;
                colorSighted.enable = true;
                copyFileContents.enable = true;
                decor.enable = false;
                fakeNitro = {
                    enable = true;
                    transformCompoundSentence = true;
                };
                forceOwnerCrown.enable = true;
                implicitRelationships.enable = true;
                mentionAvatars.enable = true;
                messageClickActions.enable = true;
                messageLogger.enable = true;
                reverseImageSearch.enable = true;
                showHiddenChannels.enable = true;
                showHiddenThings.enable = true;
                userVoiceShow.enable = true;
                voiceChatDoubleClick.enable = true;
                viewRaw.enable = true;
                volumeBooster.enable = true;
                youtubeAdblock.enable = true;
            };
        };
    };
}
