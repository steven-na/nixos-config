{ pkgs, inputs, ... }:
{
    home.packages = with pkgs; [
        cargo
        chafa
        comma
        deadnix
        fastfetch
        fd
        ffmpeg
        file
        git
        grc
        inputs.vimconf.packages.x86_64-linux.default
        claude-code
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
