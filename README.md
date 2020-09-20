Brian Dellaterra's personal dotfiles
====================================

- Clone to ~/.dotfiles using the `--recurse-submodules` flag
  (Or run `git submodule update --init --recursive` if you've already cloned without using the flag)
- Install GNU stow
- Use it to setup dotfile symlinks in home dir

Example:
--------
```
cd ~/.dotfiles
stow shell tmux git
```

