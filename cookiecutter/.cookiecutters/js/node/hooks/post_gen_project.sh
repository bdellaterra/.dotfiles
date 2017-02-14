#!/bin/bash

# Pull node dependencies into package.json
if [ '{{cookiecutter.dependencies}}' ]
then

    # Set original package.json aside as "base" for merging
    cp package.json package-base.json

    # Switch to directory containing node dependency scaffolding
    cd "{{cookiecutter.dependency_dir}}"

    # Create new package.json by merging base with packages from dependencies
    cat "$OLDPWD/package-base.json" `find -L {{cookiecutter.dependencies}} -not -path '*node_modules*' -iname "package.json"` | json --deep-merge > "$OLDPWD/package.json"

    # Copy webpack config files
    find {{cookiecutter.dependencies}} -not -path '*node_modules*' -iname 'webpack.conf*' -exec cp -L -r -t "$OLDPWD" '{}' \+

    # Copy "rc" files
    find {{cookiecutter.dependencies}} -not -path '*node_modules*' -iname '.*rc' -exec cp -L -r -t "$OLDPWD" '{}' \+

    # Copy "conf" directories from dependecies
    find {{cookiecutter.dependencies}} -not -path '*node_modules*' -type d -iname 'conf' -exec cp -L -r -t "$OLDPWD" '{}' \+

    # Switch back to project directory
    cd "$OLDPWD"

    # Cleanup
    rm package-base.json

fi
