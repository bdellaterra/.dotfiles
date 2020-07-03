#!/bin/bash
set -e

SHALLOW=1
RECURSIVE_LIST='find . ! -name "."'
SHALLOW_LIST='find . -maxdepth 1 ! -name "." -execdir basename "{}" \;'
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
-l=COMMAND, --list=COMMAND     Command to list files/directories
                               default: $LIST
-p=COMMAND, --preview=COMMAND  Command to preview highlighted line
                               default: $PREVIEW
-w=OPT, --preview-window=OPT   Preview window layout
                               default: $PREVIEW_WINDOW
USAGE
}

for i in "$@"; do
  case $i in
    -h|--help) usage; exit 0 ;;
    -l=*|--list=*) LIST="${i#*=}"; shift ;;
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

  case "$SHALLOW" in
    1) LIST="$SHALLOW_LIST" ;;
    *) LIST="$RECURSIVE_LIST" ;;
  esac

  mapfile -t targets < <(bash -c "$LIST" | fzf --multi --expect='insert,left,right,ctrl-d' --preview="$PREVIEW" --preview-window="$PREVIEW_WINDOW")

  command="${targets[0]}"
  target="${targets[1]}"

  if [[ -n "$target" ]]; then
    # Use ctrl-d to toggle shallow vs. recursive find
    if [[ "$command" == 'ctrl-d' ]]; then
      case "$SHALLOW" in
        1) unset SHALLOW ;;
        *) SHALLOW=1 ;;
      esac
      target='.' # NOOP
    fi

    # Use insert key to create a file
    # (no target, user will specify at "create file" prompt)
    [[ "$command" == 'insert' ]] && unset target

    # Use left arrow to move up a directory
    [[ "$command" == 'left' ]] && target=".."

    # Use enter (parsed as empty string) or right arrow for default action

    main "$target"
  fi
}

# Default initial target is current directory
main "${1:-$PWD}"
