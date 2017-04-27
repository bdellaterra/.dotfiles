
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


# ALIASES :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Create intermediate directories automatically w/ verbose output.
alias mkdir="mkdir -pv"

# Automatically cd to directory after it is created.
alias mkcd='_(){ mkdir $1; cd $1; }; _'


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

# *** Personal Info ***

export SELF_FIRST_NAME="Brian"
export SELF_LAST_NAME="Dellaterra"
export SELF_NICK_NAME="Smooth"
export SELF_FULL_NAME="$SELF_FIRST_NAME $SELF_LAST_NAME"
export SELF_DEFAULT_USERNAME="$(userID ${SELF_FIRST_NAME:0:1}$SELF_LAST_NAME)"
export SELF_NICK_USERNAME="$(userID $SELF_NICK_NAME)"
export SELF_GITHUB_USERNAME="$SELF_DEFAULT_USERNAME"
SELF_PUBLIC_EMAIL="${SELF_DEFAULT_USERNAME}@gmail.com"
export SELF_NOREPLY_EMAIL="${SELF_GITHUB_USERNAME}@users.noreply.github.com"

# *** Version Control Info ***

GIT_VC="Git"
GIT_VC_DIR=".git"

HG_VC="Mercurial"
HG_VC_DIR=".hg"

SVN_VC="Subversion"
SVN_VC_DIR=".svn"

CVS_VC="CVS"
CVS_VC_DIR=".cvs"

export DEFAULT_VC="$GIT_VC"
export DEFAULT_VC_DIR="$GIT_VC_DIR"
export DEFAULT_VERSION="0.1.0"

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

export DEFAULT_LICENSE_NAME="$NO_LICENSE_NAME"
export DEFAULT_LICENSE_SLUG="$NO_LICENSE_SLUG"
export DEFAULT_LICENSE_BRIEF="Distributed under the terms of the $DEFAULT_LICENSE_NAME. See the file LICENSE."


