# Local bin directory
PATH=$PATH:~/.local/bin

# Only load Liquid Prompt in interactive shells, not from a script or from scp
[[ $- = *i* ]] && source ~/liquidprompt/liquidprompt

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/base16-pop.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

