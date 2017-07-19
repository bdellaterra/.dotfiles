
# Source common rc
[[ -r ~/.shrc ]] && source ~/.shrc
# (In sh compatibility-mode)
# [[ -r ~/.shrc ]] && emulate sh -c 'source ~/.shrc'

# Lines configured by zsh-newuser-install
bindkey -e
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename '/home/smooth/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Tab-complete hidden dotfiles without specifying the '.'.
_comp_options+=(globdots)


# MAC :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Enable iTerm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# PLUGINS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# *** Zsh-AutoEnv ***
# https://github.com/Tarrasch/zsh-autoenv

AUTOENV_FILE_ENTER=.entry.sh
AUTOENV_FILE_LEAVE=.exit.sh

source ~/.zsh/plugins/zsh-autoenv/autoenv.zsh


