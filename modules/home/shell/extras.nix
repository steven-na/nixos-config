{ pkgs, inputs, ... }:
{
    home.packages = with pkgs; [
        btop
        cargo
        fastfetch
        fd
        git
        grc
        inputs.nixvim.x86_64-linux.default
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
