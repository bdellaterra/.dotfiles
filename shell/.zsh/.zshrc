
# Source common rc.
[[ -r ~/.shrc ]] && emulate sh -c 'source ~/.shrc'

# Lines configured by zsh-newuser-install
bindkey -e
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename '/home/smooth/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


# PLUGINS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# *** Zsh-AutoEnv ***
# https://github.com/Tarrasch/zsh-autoenv

AUTOENV_FILE_ENTER=.entry.sh
AUTOENV_FILE_LEAVE=.exit.sh

source ~/.zsh/plugins/zsh-autoenv/autoenv.zsh


