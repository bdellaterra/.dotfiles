
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


# ALIASES :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Create intermediate directories automatically w/ verbose output.
alias mkdir="mkdir -pv"

# Automatically cd to directory after it is created.
alias mkcd='_(){ mkdir $1; cd $1; }; _'

# List all files with long, human-readable info.
alias l='ls -lAhF $1'

# short-form for common commands
[ -x docker ] && alias d=docker
[ -x find ] && alias f=find
[ -x git ] && alias g=git
[ -x ranger ] && alias r=ranger
[ -x sudo ] && alias s=sudo
[ -x vim ] && alias v=vim

# short-form for built-in commands
alias h=history
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ......='cd ../../../../../'


# FUNCTIONS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Convert to all lowercase characters.
lowercase() {
    echo "$1" | tr 'A-Z' 'a-z'
}  

# Convert to all uppercase characters.
uppercase() {
    echo "$1" | tr 'a-z' 'A-Z'
}  

# Remove spaces.
nospaces() {
    echo "${1// /}"
}  

# Convert spaces to dashes.
dashws() {
    echo ""${1// /-}""
}  

# Convert spaces to underscores.
underscorews() {
    "echo ${1// /_}"
}  

# Remove dashes.
nodashes() {
    echo "${1//-/}"
}  

# Remove parens.
noparens() {
    echo "${1//[\(\)]/}"
}  

# Remove non-alphanumeric characters.
alphanum() {
    echo "${1//[^ _a-zA-Z0-9]/}"
}  

# Remove non-alphanumeric characters. (Keeping dashes)
alphanumdash() {
    echo "${1//[^ -_a-zA-Z0-9]/}"
}  

# Convert to safe user ID string.
userID() {
    : `nospaces "$1"`
    : `noparens "$_"`
    : `alphanum "$_"`
    : `lowercase "$_"`
    echo "$_"
}

# Convert to safe project ID string.
projID() {
    : `nospaces "$1"`
    : `noparens "$_"`
    : `alphanumdash "$_"`
    : `lowercase "$_"`
    echo "$_"
}

# Convert to safe package ID string.
pkgID() {
    : `nospaces "$1"`
    : `noparens "$_"`
    : `projID "$_"`
    : `nodashes "$_"`
    echo "$_"
}


# ENVIRONMENT VARS ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



# EXTENDED PROFILE ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Source personal profile, if present.
[[ -r ~/.personal.sh ]] && . ~/.personal.sh

# Source work profile, if present.
[[ -r ~/.work.sh ]] && . ~/.work.sh


