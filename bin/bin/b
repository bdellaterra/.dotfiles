#!/bin/bash
set -e

# Browse files using fzf
main() {
  target="$1"

  # Edit target file, or cd to target directory
  # Prompt to create file if no target specified
  if [ -d "$target" ]; then
    cd "$target"
    unset target
  else
    if [ ! -r "$target" ]; then
      read -p "Create file: " target
      mkdir -p "$(dirname "$target")" && touch "$target"
    fi
    "${EDITOR:vi}" "$target"
  fi

  { read command; read target; } < <(find . -maxdepth 1 ! -name '.' -execdir basename '{}' \; | fzf --expect='insert,left,right' --preview="/usr/bin/bat --color always --theme Nord {}" --preview-window=right:70%:wrap)

  if [ -n "$target" ]; then
    # Use insert key to create a file
    # (no target, user will specify at "create file" prompt)
    [ "$command" = 'insert' ] && unset target

    # Use left arrow to move up a directory
    [ "$command" = 'left' ] && target=".."

    # Use enter (parsed as empty string) or right arrow for default action
    # [ -z "$command" -o "$command" = 'right' ] && target="${input[1]}"

    main "$target"
  fi
}

# Default initial target is current directory
main "${1:-$PWD}"
