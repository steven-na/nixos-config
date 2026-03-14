{ ... }:
{
    programs.git = {
        enable = true;
        settings = {
            user.email = "noreply.github@stvnc.dev";
            user.name = "steven-na";
            init.defaultBranch = "main";
            pull.rebase = true;
            push.autoSetupRemote = true;
            core.editor = "nvim";
        };
        ignores = [
            ".direnv"
            "result"
            "*.secret"
            ".env"
        ];
    };
}
