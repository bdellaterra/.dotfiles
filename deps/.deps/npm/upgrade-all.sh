#/bin/bash

# Upgrade packages in each subfolder.
find . -maxdepth 2 -iname 'package.json' -execdir yarn upgrade --latest --non-interactive \;

