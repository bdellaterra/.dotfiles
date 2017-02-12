#!/bin/bash

# Pull node dependencies into package.json
if [ '{{cookiecutter.dependencies}}' ]
then

    # Set original package.json aside as "base" for merging
    cp package.json package-base.json

    # Switch to directory containing node dependency scaffolding
    cd "{{cookiecutter.dependency_dir}}"

    # Create new package.json by merging base with packages from dependencies
    cat "$OLDPWD/package-base.json" `find  -L {{cookiecutter.dependencies}} -not -path '*node_modules*' -iname "package.json"` | json --deep-merge > "$OLDPWD/package.json"

    # copy webpack config files and/or "conf" directories from dependecies
    find . -not -path '*node_modules*' -iname 'webpack.conf*' -or -type d -iname 'conf' | xargs cp -L -r -t "$OLDPWD"

    # Switch back to project directory
    cd "$OLDPWD"

    # Cleanup
    rm package-base.json

fi
