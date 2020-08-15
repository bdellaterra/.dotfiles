# *** This file is the bash entry-point. (Source it from .bash_profile for login shells) ***

# Source common rc.
[[ -r ~/.shrc ]] && . ~/.shrc

# Set command prompt
[[ -r ~/.bash_prompt ]] && . ~/.bash_prompt

# *** FZF (Command-line Fuzzy Finder) ***
# https://github.com/junegunn/fzf

# Source bash config
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

