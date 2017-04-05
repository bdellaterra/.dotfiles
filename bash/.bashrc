# Local bin directory
PATH=$PATH:~/.local/bin

# Only load Liquid Prompt in interactive shells, not from a script or from scp
[[ $- = *i* ]] && source ~/liquidprompt/liquidprompt

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/base16-pop.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL


# NVM (Node Version Manager)
export NVM_DIR="/home/smooth/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm


# Haskell
PATH=$PATH:~/.cabal/bin


# LASTLY... -------------------------------------------------------------------

# Tmux

# Source: https://wiki.archlinux.org/index.php/Tmux

# If not running interactively, do not do anything
[[ $- != *i* ]] && return

# Attach to existing deattached session or start a new session 
if [[ -z "$TMUX" ]] ;then
    ID="`tmux ls | grep -vm1 attached | cut -d: -f1`" # get the id of a deattached session
    if [[ -z "$ID" ]] ;then # if not available create a new one
        tmux new-session
    else
        tmux attach-session -t "$ID" # if available attach to it
    fi
fi

