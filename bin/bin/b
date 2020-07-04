#!/bin/bash
set -e

SHALLOW=1

# Prefer fd over find so ignored files are not listed
if command -v fd &>/dev/null; then
  RECURSIVE_FIND='fd --hidden'
  SHALLOW_FIND='fd --hidden --max-depth 1 --exec echo {/}'
else
  RECURSIVE_FIND='find . ! -name "." | sed "s:^\./::"'
  SHALLOW_FIND='find . -maxdepth 1 ! -name "." -execdir basename "{}" \;'
fi

usage() {
cat <<USAGE
usage: b [options] [target file or directory]

Browse files using fzf. If no target specified start in current directory.

Keymaps are as follows:
Enter or Right Arrow - edit file / cd to directory
Left Arrow - move up a directory
Insert - Create file named at prompt (End name with '/' to create a directory)
Ctrl-d - toggle between top-level and nested file/directory listings
Escape or Ctrl-c - exit file browser

options:
--shallow-find=COMMAND    Command to list only top-level files/directories
                          default: $SHALLOW_FIND
--recursive-find=COMMAND  Command to list nested files/directories
                          default: $RECURSIVE_FIND

Any additional options will be passed to fzf.
USAGE
}

for i in "$@"; do
  case $i in
    -h|--help) usage; exit 0 ;;
    --shallow-find=*) SHALLOW_FIND="${i#*=}"; shift ;;
    --recursive-find=*) RECURSIVE_FIND="${i#*=}"; shift ;;
    # Preserve remaining options for fzf with quoting preserved
    -*) OPTS+=("${i%%=*}=\"${i#*=}\""); shift ;;
  esac
done

main() {
  target="$1"

  if [[ -d "$target" ]]; then
    # NOTE: cd to '.' is used as a NOOP
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
  FZF="fzf --multi --expect='insert,left,right,ctrl-d' ${OPTS[@]}"

  mapfile -t targets < <(bash -c "$FIND" | bash -c "$FZF")

  command="${targets[0]}"
  target="${targets[1]}"

  if [[ -n "$target" ]]; then
    case $command in
      # Use ctrl-d to toggle shallow vs. recursive find
      ctrl-d)
        [[ $SHALLOW ]] && unset SHALLOW || SHALLOW=1
        target='.'
      ;;

      # Use insert key to create a file
      # (no target, user will specify at "Create file/directory" prompt)
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
