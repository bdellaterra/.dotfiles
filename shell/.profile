# *** General configuration for various shells (bash/zsh, interactive or not) ***

# If there's a global user profile make sure it has been sourced.
test -z "$PROFILEREAD" && . /etc/profile || true

# Source Nix profile, if present.
[[ -r ~/.nix-profile/etc/profile.d/nix.sh ]] && . ~/.nix-profile/etc/profile.d/nix.sh

# Set where command history is saved and max number of lines. 
HISTFILE=~/.history
HISTSIZE=2500 # in memory
HISTFILESIZE=2500 # on disk

# Find local executables.
PATH=$PATH:~/bin:~/local/bin

# Find locally installed packages.
PATH=$PATH:~/local
export PKG_CONFIG_PATH="$HOME/local/lib64/pkgconfig/"


# ENVIRONMENT VARS ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# *** Firefox ***

# Enbable smoother scrolling
# Source: https://lists.opensuse.org/opensuse-factory/2017-04/msg00001.html
export MOZ_USE_XINPUT2=1

