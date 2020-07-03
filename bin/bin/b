#!/bin/bash
set -e

SHALLOW=1
RECURSIVE_FIND='find . ! -name "."'
SHALLOW_FIND='find . -maxdepth 1 ! -name "." -execdir basename "{}" \;'
PREVIEW="/usr/bin/bat --color always --theme Nord {}"
PREVIEW_WINDOW="right:70%:wrap"

usage() {
cat <<USAGE
usage: b [options] [target file or directory]

Browse files using fzf. If no target specified start in current directory.

Keymaps are as follows:
Enter or Right Arrow - edit file / cd to directory
Left Arrow - move up a directory
Insert - Create file named at prompt (End name with '/' to create a directory)
Escape or Ctrl-c - exit file browser

options:
-s=COMMAND, --shallow-find=COMMAND    Command to list files/directories 1 level deep
                                      default: $SHALLOW_FIND
-r=COMMAND, --recursive-find=COMMAND  Command to list nested files/directories
                                      default: $RECURSIVE_FIND
-p=COMMAND, --preview=COMMAND         Command to preview highlighted line
                                      default: $PREVIEW
-w=OPT, --preview-window=OPT          Preview window layout
                                      default: $PREVIEW_WINDOW
USAGE
}

for i in "$@"; do
  case $i in
    -h|--help) usage; exit 0 ;;
    -s=*|--shallow-find=*) SHALLOW_FIND="${i#*=}"; shift ;;
    -r=*|--recursive-find=*) RECURSIVE_FIND="${i#*=}"; shift ;;
    -p=*|--preview=*) PREVIEW="${i#*=}"; shift ;;
    -w=*|--preview-window=*) PREVIEW_WINDOW="${i#*=}"; shift ;;
    --*|-?) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

main() {
  target="$1"

  if [[ -d "$target" ]]; then
    cd "$target"
  else
    if [[ ! -r "$target" ]]; then
      read -p "Create file/directory: " target
      if [[ "$target" =~ '/$' ]]; then
        mkdir -p "$target"
      else
        mkdir -p "$(dirname "$target")" && touch "$target"
      fi
    fi
    "${EDITOR:vi}" "$target"
  fi

  [[ $SHALLOW ]] && FIND="$SHALLOW_FIND" || FIND="$RECURSIVE_FIND"

  mapfile -t targets < <(
    bash -c "$FIND" | fzf --multi --expect='insert,left,right,ctrl-d' --preview="$PREVIEW" --preview-window="$PREVIEW_WINDOW"
  )

  command="${targets[0]}"
  target="${targets[1]}"

  if [[ -n "$target" ]]; then
    case $command in
      # Use ctrl-d to toggle shallow vs. recursive find
      ctrl-d)
        [[ $SHALLOW ]] && unset SHALLOW || SHALLOW=1
        target='.' # cd to '.' is a NOOP
      ;;

      # Use insert key to create a file
      # (no target, user will specify at "create file" prompt)
      insert)
        unset target
      ;;

      # Use left arrow to move up a directory
      left)
        target=".."
      ;;

      # Use enter (parsed as empty string) or right arrow for default action
    esac

    main "$target"
  fi
}

# Default initial target is current directory
main "${1:-$PWD}"
