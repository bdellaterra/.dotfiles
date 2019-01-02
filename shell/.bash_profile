# *** This is the entry point for bash "login shells" (like TTY or SSH, not GUI) ***

# Source common profile.
[[ -r ~/.profile ]] && . ~/.profile

# Source rc for interactive shells
[[ -r ~/.bashrc ]] && . ~/.bashrc

