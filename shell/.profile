
# Make sure the global user profile has been sourced.
test -z "$PROFILEREAD" && . /etc/profile || true

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


# FUNCTIONS :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

lowercase() {
    echo "$1" | tr 'A-Z' 'a-z'
}  

uppercase() {
    echo "$1" | tr 'a-z' 'A-Z'
}  

nospaces() {
    echo "${1// /}"
}  

dashws() {
    echo ""${1// /-}""
}  

underscorews() {
    "echo ${1// /_}"
}  

nodashes() {
    echo "${1//-/}"
}  

noparens() {
    echo "${1//[\(\)]/}"
}  

alphanum() {
    echo "${1//[^ _a-zA-Z0-9]/}"
}  

alphanumdash() {
    echo "${1//[^ -_a-zA-Z0-9]/}"
}  

userID() {
    : `nospaces "$1"`
    : `noparens "$_"`
    : `alphanum "$_"`
    : `lowercase "$_"`
    echo "$_"
}

projID() {
    : `nospaces "$1"`
    : `noparens "$_"`
    : `alphanumdash "$_"`
    : `lowercase "$_"`
    echo "$_"
}

pkgID() {
    : `nospaces "$1"`
    : `noparens "$_"`
    : `projID "$_"`
    : `nodashes "$_"`
    echo "$_"
}


# ENVIRONMENT VARS ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# *** Personal Info ***

SELF_FIRST_NAME="Brian"
SELF_LAST_NAME="Dellaterra"
SELF_NICK_NAME="Smooth"
SELF_FULL_NAME="$SELF_FIRST_NAME $SELF_LAST_NAME"
SELF_PUBLIC_EMAIL="bdellaterra@voodooglobe.com"
SELF_NOREPLY_EMAIL="bdellaterra@users.noreply.github.com"
SELF_DEFAULT_USERNAME="$(userID ${SELF_FIRST_NAME:0:1}$SELF_LAST_NAME)"
SELF_NICK_USERNAME="$(userID $SELF_NICK_NAME)"
SELF_GITHUB_USERNAME="$SELF_DEFAULT_USERNAME"

# *** License Info ***

NO_LICENSE_NAME="Copyright held by $SELF_FULL_NAME"
NO_LICENSE_SLUG="UNLICENSED"

APACHE2_LICENSE_NAME="Apache License 2.0"
APACHE2_LICENSE_SLUG="Apache-2.0"

BSD2_LICENSE_NAME="BSD 2-Clause \"Simplified\" License"
BSD2_LICENSE_SLUG="BSD-2-Clause"

BSD4_LICENSE_NAME="BSD 3-Clause \"New\" or \"Revised\" License"
BSD3_LICENSE_SLUG="BSD-3-Clause"

ISC_LICENSE_NAME="ISC License"
ISC_LICENSE_SLUG="ISC"

GPL_LICENSE_NAME="GNU General Public License v3.0"
GPL_LICENSE_SLUG="GPL-3.0"

LGPL_LICENSE_NAME="GNU Lesser General Public License v3.0"
LGPL_LICENSE_SLUG="LGPL-3.0"

MIT_LICENSE_NAME="MIT License"
MIT_LICENSE_SLUG="MIT"


# *** Default Project Info ***

PROJECT_VC_DIR=".git"
PROJECT_NAME="My NVM-App (WITH_UNDERSCORES)"
PROJECT_SLUG="$(projID $PROJECT_NAME)"
PROJECT_PACKAGE_ID="$(pkgID $PROJECT_NAME)"
PROJECT_BRIEF="$PROJECT_NAME app"
PROJECT_AUTHOR="$SELF_FULL_NAME"
PROJECT_EMAIL="$SELF_NOREPLY_EMAIL"
PROJECT_GITHUB_USERNAME="$SELF_GITHUB_USERNAME"
PROJECT_VERSION="0.1.0"
PROJECT_LICENSE_NAME="$NO_LICENSE_NAME"
PROJECT_LICENSE_SLUG="$NO_LICENSE_SLUG"
PROJECT_LICENSE_BRIEF="Distributed under the terms of the $PROJECT_LICENSE_NAME. See the file LICENSE."

