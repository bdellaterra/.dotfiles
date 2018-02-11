Project Scaffolding
===================

```
# create project folder
mkdir -p ~/dev/new-project

# initialize project vars (fill in vim-generated template)
vim ~/dev/new-project/.entry.sh

# nav to project dir (.entry.sh runs via zsh-autoenv plugin)
cd ~/dev/new-project

# pull-in dependencies (trailing slashes on deps are required)
rsync -Lr ~/deps/js/dep1/ ~/deps/js/dep2/ ./

# initialize and install
init-node-project
```

