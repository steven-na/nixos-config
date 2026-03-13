{ pkgs, inputs, ... }:
{
    home.packages = with pkgs; [
        cargo
        chafa
        claude-code
        comma
        deadnix
        fastfetch
        fd
        ffmpeg-full
        file
        git
        grc
        inputs.vimconf.packages.x86_64-linux.default
        jq
        just
        lazygit
        nix-index
        nix-prefetch-git
        nixfmt
        ripgrep
        statix
        ts
        unzip
        wget
    ];
}
