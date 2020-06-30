#!/bin/bash
set -e

persist=1

main() {
  target="$1"

  if [ -d "$target" ]; then
    cd "$target"
    unset target
  fi

  if [ $persist ]; then
    query=${target:+--query="$target"}
  fi

  # Use parens to process results as array
  result=$(fd --maxdepth 1 '.*' | fzf --expect='insert,left,right' --preview="cat {}" --preview-window=right:70%:wrap $query)
  input=($result)

  if [ ${#input[@]} -ge 2 ]; then
    command=${input[0]}
    target=${input[1]}

    # Use insert key to create a file
    if [ "$command" = 'insert' ]; then
      read -p "Create file: " target
      mkdir -p "$(dirname "$target")" && touch "$target"
      command='edit'
    fi

    # Use left arrow to move up a directory
    if [ "$command" = 'left' ]; then
      command='cd'
      target=".."
    fi

    # Use right arrow as an alias for enter key
    if [ "$command" = 'right' ]; then
      command='default'
    fi
  else
    # Use enter (or right arrow) to edit a file or enter a directory
    command='default'
    target=$input
  fi

  if [ "$command" = 'default' ]; then
    if [ -d "$target" ]; then
      command='cd'
    else
      command='edit'
      ${EDITOR:vi} "$target"
    fi
  fi

  main "$target"
}

main "${1:$PWD}"
