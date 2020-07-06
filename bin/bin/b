#!/bin/bash
set -e

# Prefer fd over find so ignored files are not listed
if command -v fd &>/dev/null; then
  RECURSIVE_FIND='fd --hidden'
  SHALLOW_FIND='fd --hidden --max-depth 1 --exec echo {/}'
else
  RECURSIVE_FIND='find . ! -name "." | sed "s:^\./::"'
  SHALLOW_FIND='find . -maxdepth 1 ! -name "." -execdir basename "{}" \;'
fi

declare -A KEYMAP
KEYMAP['right']="enter directory or edit file"
KEYMAP['left']="cd to parent directory"
KEYMAP['ctrl-r']="move targets"
KEYMAP['alt-r']="rename targets"
KEYMAP['ctrl-d']="delete targets"
KEYMAP['alt-d']="move and rename targets"
KEYMAP['ctrl-s']="copy targets"
KEYMAP['alt-s']="copy and rename targets"
KEYMAP['ctrl-b']="set base directory"
KEYMAP['alt-b']="set alternate directory"
KEYMAP['ctrl-\']="cd to alternate directory"
KEYMAP['ctrl-/']="cd to deeper directory using cache"
KEYMAP['alt-h']="toggle display of hidden files"
KEYMAP['alt-i']="toggle display of ignored files"
KEYMAP['alt-a']="toggle all nested vs. only top-level files"

KEYS="$(printf ",%s" "${!KEYMAP[@]}" | cut -c2-)"
KEY_USAGE="$(for k in "${!KEYMAP[@]}"; do echo "$k - ${KEYMAP[$k]}"; done)"

usage() {
cat <<USAGE
usage: b [options] [target file or directory]

Browse files using fzf. If no target specified start in current directory.

Keymaps are as follows:
escape or ctrl-c - exit file browser
enter - enter directory or edit file
$(echo "$KEY_USAGE" | sort)

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

SHALLOW=1               # Start with only top-level files/directories shown
START_DIR="${1:-$PWD}"  # Default initial target is current directory

main() {
  if [[ $# -eq 1 ]]; then
    target="$1"
    if [[ -d "$target" ]]; then
      cd "$target"
    else
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
  PROMPT="${#saved_targets[@]}> "
  FZF="fzf --prompt='$PROMPT' --multi --expect='$KEYS' ${OPTS[@]}"
  { read command; mapfile -t targets; } < <(bash -c "$FIND" | bash -c "$FZF")

  # Use Escape or ctrl-c to exit
  [[ "${#targets[@]}" -eq 0 ]] && break

  case $command in
    # Use alt-a to toggle showing "all" nested files/directories
    # below current directory vs. only those at top-level
    alt-a)
      [[ $SHALLOW ]] && unset SHALLOW || SHALLOW=1
      targets=()
    ;;

    # Use del to delete targets
    del)
      REMOVE="rm -rI ${targets[@]}"
      bash -c "$REMOVE"
      targets=()
    ;;

    # Use ctrl-s to save targets
    ctrl-s)
      for t in "${targets[@]}"; do
        saved_targets=("${saved_targets[@]}" $(readlink -f "$t"))
      done
      echo "${saved_targets[@]}"
      targets=()
    ;;

    # Use insert to copy saved targets to current directory
    insert)
      COPY="cp -ri ${saved_targets[@]} $PWD/"
      bash -c "$COPY"
      targets=()
    ;;

    # Use ctrl-v to move saved targets to current directory
    ctrl-v)
      MOVE="mv -i ${saved_targets[@]} $PWD/"
      bash -c "$MOVE"
      targets=()
    ;;

    # Use ctrl-d to create a directory
    # Use alt-d to create a directory and cd to it immediately
    ctrl-d|alt-d)
      targets=()
      read -p "Create directory: " target
      if [[ -n "$target" ]]; then
        mkdir -p "$target"
        [[ "$command" = 'alt-d' ]] && targets=("$target")
      fi
    ;;

    # Use ctrl-f to create a file
    # Use alt-f to create a file and edit it immediately
    ctrl-f|alt-f)
      targets=()
      read -p "Create file: " target
      if [[ -n "$target" ]]; then
        mkdir -p "$(dirname "$target")" && touch "$target"
        [[ "$command" = 'alt-f' ]] && targets=("$target")
      fi
    ;;

    # Use left arrow to move up a directory (not past initial directory)
    left)
      echo "$PWD"
      targets=()
      [[ "$PWD" != "$START_DIR" ]] && targets=("..")
    ;;

    # Use enter (parsed as empty string) or right arrow for default action
  esac

  main "${targets[@]}"
}

# Default initial target is current directory
main "$START_DIR"
