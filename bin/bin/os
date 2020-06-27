#!/bin/bash

DISTRO_REGEX="\b(NAME|DISTRIB.ID|DISTRIBUTOR.ID)[:=]\s*\"([^\"]*)\""
DISTRO_CAPTURE=2
VERSION_REGEX="\b(VERSION.ID|RELEASE)[:=]\s*\"([^\"]*)\""
VERSION_CAPTURE=2

[[ `command -v uname` ]] && OS=$(uname -s)
RELEASE=$(cat /etc/*release | uniq)
[[ -r /etc/os-release ]] && RELEASE=$(cat /etc/os-release)
DISTRO="$RELEASE"
[[ $RELEASE =~ $DISTRO_REGEX ]] && DISTRO=${BASH_REMATCH[$DISTRO_CAPTURE]}
[[ $RELEASE =~ $VERSION_REGEX ]] && VERSION=${BASH_REMATCH[$VERSION_CAPTURE]}

# Reference: https://distrowatch.com/dwres.php?resource=package-management

# if [[ $DISTRO =~ 'Fedora|CentOS' ]]
# then
#   REFRESH='dnf check-update'
#   LIST='rpm -qa'
#   SHOW='dnf info'
#   SEARCH='dnf list'
#   REGEX_SEARCH='dnf search'
#   PATH_SEARCH='dnf provides'
#   INSTALL='dnf install'
#   REMOVE='dnf erase'
#   UPGRADE='dnf update'
#   FULL_UPGRADE=''
#   DISTRO_UPGRADE=''
# fi
#
# if [[ $DISTRO =~ 'Debian|Ubuntu' ]]
# then
#   REFRESH='apt-get update'
#   LIST='cat /etc/apt/sources.list'
#   SHOW='apt-cache show'
#   SEARCH='apt-cache search'
#   REGEX_SEARCH='apt-cache search'
#   PATH_SEARCH='apt-file search'
#   INSTALL='apt-get install'
#   REMOVE='apt-get remove'
#   UPGRADE='apt-get upgrade'
#   FULL_UPGRADE=''
#   DISTRO_UPGRADE=''
# fi

if [[ $DISTRO =~ 'openSUSE' ]]
then
  REFRESH='zypper refresh'
  LIST='zypper search -is'
  SHOW='zypper info'
  SEARCH='zypper search'
  REGEX_SEARCH='zypper search'
  PATH_SEARCH='zypper search --provides --match-exact'
  INSTALL='zypper install'
  REMOVE='zypper remove'
  UPGRADE='zypper update -t package'
  FULL_UPGRADE='zypper update -t package'
  DISTRO_UPGRADE='zypper dup --no-allow-vendor-change'
fi

# if [[ $DISTRO =~ 'Mandriva|Mageia' ]]
# then
#   REFRESH='urpmi.update -a'
#   LIST='rpm -qa'
#   SHOW=''
#   SEARCH='urpmq'
#   REGEX_SEARCH='urpmq --fuzzy'
#   PATH_SEARCH='urpmf'
#   INSTALL='urpmi'
#   REMOVE='urpme'
#   UPGRADE='urpmi --auto-select'
#   FULL_UPGRADE=''
#   DISTRO_UPGRADE=''
# fi
#
# if [[ $DISTRO =~ 'Gentoo' ]]
# then
#   REFRESH='emerge --sync'
#   LIST='qlist -I'
#   SHOW=''
#   SEARCH='emerge --search'
#   REGEX_SEARCH='emerge --search'
#   PATH_SEARCH='equery belongs'
#   INSTALL='emerge'
#   REMOVE='emerge -aC'
#   UPGRADE='emerge'
#   FULL_UPGRADE=''
#   DISTRO_UPGRADE='emerge -NuDa world'
# fi
#
# if [[ $DISTRO =~ 'FreeBSD' ]]
# then
#   REFRESH='pkg update'
#   LIST='pkg info'
#   SHOW='pkg info'
#   SEARCH='pkg search'
#   REGEX_SEARCH='pkg search -D'
#   PATH_SEARCH=''
#   INSTALL='pkg install'
#   REMOVE='pkg remove'
#   UPGRADE='freebsd-update fetch install'
#   FULL_UPGRADE=''
#   DISTRO_UPGRADE='pkg upgrade'
# fi

# if [[ $DISTRO =~ 'Arch' ]]
# then
#   REFRESH='pacman -Sy'
#   LIST='pacman -Q'
#   SHOW=''
#   SEARCH='pacman -Ss'
#   REGEX_SEARCH='pacman -Ss'
#   PATH_SEARCH='pacman -Qo'
#   INSTALL='pacman -S'
#   REMOVE='pacman -R'
#   UPGRADE='pacman -S'
#   FULL_UPGRADE=''
#   DISTRO_UPGRADE='pacman -Su'
# fi

# if [[ $DISTRO =~ 'Alpine' ]]
# then
#   REFRESH='apk update'
#   LIST='apk info'
#   SHOW=''
#   SEARCH='apk search'
#   REGEX_SEARCH='apk search'
#   PATH_SEARCH=''
#   INSTALL='apk add'
#   REMOVE='apk del'
#   UPGRADE='apk upgrade'
#   FULL_UPGRADE=''
#   DISTRO_UPGRADE=''
# fi

if [[ $# -eq 0 ]]
then
  echo "$DISTRO"
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      echo "os - attempt to identify or update the operating system"
      echo " "
      echo "os [options]"
      echo " "
      echo "options:"
      echo "-n, --name                 show distribution name (default output)"
      echo "-h, --help                 show brief help message"
      echo "-v, --verbose              show verbose OS information"
      echo "-l, --list                 list installed packages"
      echo "-w, --what, --show         show info for package"
      echo "-c, --current, --refresh   get the latest package listings"
      echo "-s, --search               search for specified package"
      echo "-g, --grep                 search for specified pattern"
      echo "-p, --path                 search by specified file path"
      echo "-i, --install              install specified package"
      echo "-r, --remove               uninstall specified package"
      echo "-u, --upgrade              upgrade packages"
      echo "-f, --full-upgrade         upgrade packages, removing obsolete dependencies"
      echo "-d, --distribution-upgrade major distribution upgrade"
      exit 0
      ;;
    -n|--name)
      echo "$DISTRO"
      break
      ;;
    -v|--verbose)
      echo "$OS:$DISTRO:$VERSION"
      break
      ;;
    -l|--list)
      [[ $LIST ]] || exit 1;
      echo "LISTING INSTALLED PACKAGES..."
      echo $LIST
      $LIST
      break
      ;;
    -w|--which|--show)
      # [[ $SHOW ]] || exit 1;
      echo "SHOWING INFO FOR PACKAGES..."
      shift
      echo $SHOW $@
      $SHOW $@
      break
      ;;
    -c|--current|--refresh)
      [[ $REFRESH ]] || exit 1;
      echo "UPDATING PACKAGE LISTING..."
      echo $REFRESH
      $REFRESH
      break
      ;;
    -s|--search)
      [[ $SEARCH ]] || exit 1;
      echo "SEARCHING PACKAGES..."
	  shift
      echo $SEARCH $@
      $SEARCH $@
      break
      ;;
    -g|--grep)
      [[ $REGEX_SEARCH ]] || exit 1;
      echo "SEARCHING PACKAGES FOR PATTERNS..."
	  shift
      echo $REGEX_SEARCH $@
      $REGEX_SEARCH $@
      break
      ;;
    -p|--path)
      [[ $PATH_SEARCH ]] || exit 1;
      echo "SEARCHING PACKAGES FOR FILE PATHS..."
	  shift
      echo $PATH_SEARCH $@
      $PATH_SEARCH $@
      break
      ;;
    -i|--install)
      [[ $INSTALL ]] || exit 1;
      echo "INSTALLING PACKAGES..."
	  shift
      echo $INSTALL $@
      $INSTALL $@
      break
      ;;
    -r|--remove)
      [[ $REMOVE ]] || exit 1;
      echo "REMOVING PACKAGES..."
	  shift
      echo $REMOVE $@
      $REMOVE $@
      break
      ;;
    -u|--upgrade)
      [[ $UPGRADE ]] || exit 1;
      echo "UPGRADING PACKAGES..."
	  shift
      echo $UPGRADE $@
      $UPGRADE $@
      break
      ;;
    -f|--full-upgrade)
      [[ $FULL_UPGRADE ]] || exit 1;
      echo "UPGRADING PACKAGES AND REMOVING OLD DEPENDENCIES..."
	  shift
      echo $FULL_UPGRADE $@
      $FULL_UPGRADE $@
      break
      ;;
    -d|--distro-upgrade|--distribution-upgrade)
      [[ $DISTRO_UPGRADE ]] || exit 1;
      echo "UPGRADING DISTRIBUTION..."
	  shift
      echo $DISTRO_UPGRADE $@
      $DISTRO_UPGRADE $@
      break
      ;;
    -*)
      echo "unknown option: $1" >&2;
      exit 1
      ;;
  esac
done
