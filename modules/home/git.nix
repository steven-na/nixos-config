{ ... }:
{
    programs.git = {
        enable = true;
        settings = {
            user.email = "blakescampbell04@gmail.com";
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
