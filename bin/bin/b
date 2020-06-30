#!/bin/bash

# Browse files using fzf

set -e

persist=1

main() {
  target="$1"

  if [ -d "$target" ]; then
    cd "$target"
    unset target
  else
    if [ ! -r "$target" ]; then
      read -p "Create file: " target
      mkdir -p "$(dirname "$target")" && touch "$target"
    fi
    ${EDITOR:vi} "$target"
  fi

  # Use parens to process results as array
  result=$(fd --maxdepth 1 '.*' | fzf --expect='insert,left,right' --preview="${VIEWER:cat} {}" --preview-window=right:70%:wrap)
  input=($result)

  if [ ${#input[@]} -ge 2 ]; then
    command=${input[0]}

    # Use insert key to create a file
    # (no target, user will specify at "create file" prompt)

    # Use left arrow to move up a directory
    [ "$command" = 'left' ] && target=".."

    # Use right arrow as an alias for enter key
    [ "$command" = 'right' ] && target=${input[1]}
  else
    # Use enter (or right arrow) to edit a file or enter a directory
    target=$input
  fi

  main "$target"
}

main "${1:-$PWD}"
