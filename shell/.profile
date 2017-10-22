
# If there's a global user profile make sure it has been sourced.
test -z "$PROFILEREAD" && . /etc/profile || true

# Source Nix profile, if present.
[[ -r ~/.nix-profile/etc/profile.d/nix.sh ]] && . ~/.nix-profile/etc/profile.d/nix.sh

# Set where command history is saved and max number of lines. 
HISTFILE=~/.history
HISTSIZE=2500
HISTFILESIZE=2500

# Find local executables.
PATH=$PATH:~/bin:~/local/bin

# Find locally installed packages.
PATH=$PATH:~/local
export PKG_CONFIG_PATH="$HOME/local/lib64/pkgconfig/"

# *** NVM (Node Version Manager) ***
# https://github.com/creationix/nvm

# Set path to NVM and initialize.
export NVM_DIR=~/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Set path to yarn
# https://yarnpkg.com
export PATH="$HOME/.yarn/bin:$PATH"


# ENVIRONMENT VARS ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


