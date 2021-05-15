#!/bin/bash

OS="$(dirname "${BASH_SOURCE[0]}")/../bin/bin/os"
if [[ ! -x "$OS" ]]; then
  echo "Unable to determine operating system"
  exit 1
fi

DISTRO=`$OS --name`
if [[ $DISTRO =~ 'Debian' || $DISTRO =~ 'Ubuntu'  ]]; then
  sudo $OS --install apt-file && sudo apt-file update
fi

# sudo $OS --install docker docker-compose
# sudo systemctl enable docker
# sudo usermod -G docker -s "$USER"

sudo $OS --install git
sudo $OS --install stow
sudo $OS --install curl
if [[ $DISTRO =~ 'SUSE' ]]; then
  sudo $OS --install mr
else
  sudo $OS --install myrepos
fi

sudo $OS --install vim
if [[ $DISTRO =~ 'SUSE' ]]; then
  sudo $OS --install vim-data
  sudo $OS --install psmisc
fi

sudo $OS --install rg
sudo $OS --install fzf

sudo $OS --install tmux

sudo $OS --install fd
sudo $OS --install exa
sudo $OS --install bat

sudo $OS --install ranger
sudo $OS --install htop
sudo $OS --install strace
sudo $OS --install fortune

sudo $OS --install zsh
sudo chsh -s /bin/zsh "$USER"
