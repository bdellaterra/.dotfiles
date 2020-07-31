#!/bin/bash

OS='../bin/bin/os'
if [[ ! -x "$OS" ]]; then
  echo "Unable to determine operating system"
  exit 1
fi

DISTRO=`$OS --name`
if [[ $DISTRO =~ 'Debian' || $DISTRO =~ 'Ubuntu'  ]]; then
  sudo $OS --install apt-file && sudo apt-file update
fi

sudo $OS --install git
sudo $OS --install stow

sudo $OS --install curl
sudo $OS --install vim

sudo $OS --install rg
sudo $OS --install fzf

sudo $OS --install tmux

sudo $OS --install fd
sudo $OS --install exa

sudo $OS --install htop

sudo $OS --install zsh
sudo chsh -s /bin/zsh "$USER"
