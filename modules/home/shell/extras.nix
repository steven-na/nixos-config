{ pkgs, ... }:
{
    home.packages = with pkgs; [
        bat
        btop
        cargo
        fastfetch
        fd
        fzf
        git
        grc
        jq
        just
        lazygit
        nix-prefetch-git
        ripgrep
        unzip
        wget
        yazi
    ];
}
