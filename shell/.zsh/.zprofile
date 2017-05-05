
# Source common profile.
[[ -r ~/.profile ]] && emulate sh -c 'source ~/.profile'

# Set history file size to value from bash-compatible variable.
SAVEHIST=HISTFILESIZE

# Bind alt-m to insert previous word from the current line
bindkey '^[m' copy-prev-shell-word

# Bind alt-k to kill word before cursor in vi-style
bindkey '^[k' vi-backward-kill-word

