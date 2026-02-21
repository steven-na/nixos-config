# {
#     programs.foot = {
#         enable = true;
#         extraConfig = ''
#             include=~/.cache/wallust/foot-colors.ini
#         '';
#         settings = {
#             main = {
#                 font = "JetBrainsMono Nerd Font:size=12";
#                 pad = "8x8";
#                 shell = "fish";
#             };
#             mouse.hide-when-typing = "yes";
#             scrollback.lines = 10000;
#             url.launch = "xdg-open \${url}";
#
#             # Colors sourced from wallust at runtime via include
#             # foot supports @include directive
#         };
#     };
#     # foot config includes the generated colors file
#     # add to foot settings: include = ~/.cache/wallust/foot-colors.ini
# }
{
    programs.foot.enable = true;

    xdg.configFile."foot/foot.ini".text = ''
        include=~/.cache/wallust/foot-colors.ini

        [main]
        font=JetBrainsMono Nerd Font:size=12
        pad=8x8
        shell=fish

        [mouse]
        hide-when-typing=yes

        [scrollback]
        lines=10000

        [url]
        launch=xdg-open ''${url}
    '';
}
