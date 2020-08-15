
# Source common rc
[[ -r ~/.shrc ]] && source ~/.shrc
# (In sh compatibility-mode)
# [[ -r ~/.shrc ]] && emulate sh -c 'source ~/.shrc'

# Set command prompt
[[ -r ~/.zsh/.zsh_prompt ]] && . ~/.zsh/.zsh_prompt

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

# Bind alt-m to insert previous word from the current line
bindkey '^[m' copy-prev-shell-word

# Bind alt-k to kill word before cursor in vi-style
bindkey '^[k' vi-backward-kill-word


# *** FZF (Command-line Fuzzy Finder) ***
# https://github.com/junegunn/fzf

# Source zsh config
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# MAC :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Enable iTerm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# PLUGINS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# *** Zsh-AutoEnv ***
# https://github.com/Tarrasch/zsh-autoenv

AUTOENV_FILE_ENTER=.entry.sh
AUTOENV_FILE_LEAVE=.exit.sh

source ~/.zsh/plugins/zsh-autoenv/autoenv.zsh

# Edit and (re)source folder scoped variables
alias reentry="${EDITOR:-vi} .entry.sh && source .entry.sh"

