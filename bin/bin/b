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

for arg in "$@"; do
  case $arg in
    -h|--help) usage; exit 0 ;;
    --shallow-find=*) SHALLOW_FIND="${arg#*=}"; shift ;;
    --recursive-find=*) RECURSIVE_FIND="${arg#*=}"; shift ;;
    # Save remaining options for fzf with quoting preserved
    -*) OPTS+=("${arg%%=*}=\"${arg#*=}\""); shift ;;
  esac
done

main() {
  if [[ $# -le 1 ]]; then
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
      [[ -n "$target" ]] && "${EDITOR:vi}" "$target"
    fi
  elif [[ $# -gt 1 ]]; then
    EDIT="${EDITOR:vi}"
    for f in "$@"; do
      EDIT="$EDIT \"$f\""
    done
    bash -c "$EDIT"
  fi

  # CYCLE INTO FZF
  [[ $SHALLOW ]] && FIND="$SHALLOW_FIND" || FIND="$RECURSIVE_FIND"
  FZF="fzf --multi --expect='insert,del,left,right,ctrl-d,ctrl-s,ctrl-n' ${OPTS[@]}"
  { read command; mapfile -t targets; } < <(bash -c "$FIND" | bash -c "$FZF")

  # Use Escape or ctrl-c to exit
  [[ "${#targets[@]}" -eq 0 ]] && break

  case $command in
    # Use ctrl-d to toggle shallow vs. recursive find
    ctrl-d)
      [[ $SHALLOW ]] && unset SHALLOW || SHALLOW=1
      targets=('.')
    ;;

    # Use del to delete targets
    del)
      REMOVE="rm -rI ${targets[@]}"
      bash -c "$REMOVE"
      targets=('.')
    ;;

    # Use ctrl-s to save targets
    ctrl-s)
      saved_targets=("${saved_targets[@]}" "${targets[@]}")
      echo "${saved_targets[@]}"
      targets=('.')
    ;;

    # Use insert key to create a file
    # (no target, user will specify at "Create file/directory" prompt)
    ctrl-n)
      targets=()
    ;;

    # Use left arrow to move up a directory
    left)
      targets=("..")
    ;;

    # Use enter (parsed as empty string) or right arrow for default action
  esac

  main "${targets[@]}"
}

# Default initial target is current directory
main "${1:-$PWD}"
