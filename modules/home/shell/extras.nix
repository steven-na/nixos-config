{ pkgs, inputs, ... }:
{
    home.packages = with pkgs; [
        cargo
        chafa
        comma
        deadnix
        fastfetch
        fd
        git
        grc
        inputs.nixcats.packages.x86_64-linux.default
        jq
        just
        lazygit
        nix-index
        nix-prefetch-git
        nixfmt
        ripgrep
        statix
        unzip
        wget
    ];
}
