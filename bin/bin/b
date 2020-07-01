#!/bin/bash
set -e

LIST="find . -maxdepth 1 ! -name '.' -execdir basename '{}' \;"
PREVIEW="/usr/bin/bat --color always --theme Nord {}"
PREVIEW_WINDOW="right:70%:wrap"

for i in "$@"; do
  case $i in
    -h|--help)
      echo "b - browse files using fzf"
      echo " "
      echo "usage: b [options] [target file or directory]"
      echo " "
      echo "options:"
      echo "-l=COMMAND, --list=COMMAND     Command to list files/directories"
      echo "                               default: $LIST"
      echo "-p=COMMAND, --preview=COMMAND  Command to preview highlighted line ({})"
      echo "                               default: $PREVIEW"
      echo "-w=OPT, --preview-window=OPT   Preview window layout"
      echo "                               default: $PREVIEW_WINDOW"
      echo " "
      exit 0
      ;;
    -l=*|--list=*) LIST="${i#*=}"; shift ;;
    -p=*|--preview=*) PREVIEW="${i#*=}"; shift ;;
    -w=*|--preview-window=*) PREVIEW_WINDOW="${i#*=}"; shift ;;
  esac
done

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

  { read command; read target; } < <(bash -c "$LIST" | fzf --expect='insert,left,right' --preview="$PREVIEW" --preview-window="$PREVIEW_WINDOW")

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
