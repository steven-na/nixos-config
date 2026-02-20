{
    inputs,
    pkgs,
    ...
}:
{
    imports = [
        inputs.spicetify-nix.homeManagerModules.spicetify
    ];

    programs.spicetify =
        let
            spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
        in
        {
            enable = true;

            enabledExtensions = with spicePkgs.extensions; [
                beautifulLyrics
                starRatings
                queueTime
                hidePodcasts
                shuffle # shuffle+
            ];
            enabledSnippets = with spicePkgs.snippets; [
                pointer
            ];

            theme = spicePkgs.themes.comfy;
            colorScheme = "Nord";

        };
}
