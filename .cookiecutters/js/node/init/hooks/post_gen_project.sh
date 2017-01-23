#!/bin/bash

# Pull node dependencies into package.json

cp package.json package-base.json

cd "{{cookiecutter.dependency_dir}}"

cat "$OLDPWD/package-base.json" `find  {{cookiecutter.dependencies}} -iname "package.json"` | json --deep-merge > "$OLDPWD/package.json"

cd "$OLDPWD"

rm package-base.json