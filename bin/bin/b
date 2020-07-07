#!/bin/bash
set -e

# Start with only top-level files/directories displayed
SHALLOW=1

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
KEYMAP['ctrl-r']="move targets to directory named at prompt"
KEYMAP['alt-r']="rename targets"
KEYMAP['ctrl-x']="delete selected targets"
KEYMAP['alt-x']="move and rename selected targets"
KEYMAP['ctrl-s']="copy selected targets to directory named at prompt"
KEYMAP['alt-s']="copy and rename selected targets"
KEYMAP['ctrl-d']="Enter directory named at prompt, creating it if necessary"
KEYMAP['alt-d']="create directory without entering it"
KEYMAP['ctrl-f']="Edit file named at prompt, creating it if necessary"
KEYMAP['alt-f']="create file without editing it"
KEYMAP['alt-b']="bookmark current directory"
KEYMAP['alt-u']="un-bookmark current directory and go to next bookmark"
KEYMAP['alt-right']="go to next bookmarked directory"
KEYMAP['alt-left']="go to previous bookmarked directory"
KEYMAP['alt-up']="select and enter bookmarked directory"
KEYMAP['alt-b']="bookmark current directory"
KEYMAP['ctrl-space']="set base directory"
KEYMAP['alt-space']="set alternate directory"
KEYMAP['ctrl-/']="cd to deeper path using cached information"
KEYMAP['alt-/']="cd to alternate directory"
KEYMAP['alt-h']="toggle display of hidden files"
KEYMAP['alt-i']="toggle display of ignored files"
KEYMAP['alt-a']="toggle all nested vs. only top-level files"

KEYS="$(printf ",%s" "${!KEYMAP[@]}" | cut -c2-)" # comma-separated list for fzf
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
--help                                Show this help text
--recursive,-r                        Show nested files/direcories at start
--shallow-find=COMMAND,-sf=COMMAND    Command to list only top-level files/directories
                                      default: $SHALLOW_FIND
--recursive-find=COMMAND,-rf=COMMAND  Command to list nested files/directories
                                      default: $RECURSIVE_FIND
--base-directory=DIR,-bd=DIR          Specify a base directory instead of deriving it from target
--alternate-directory=DIR,-ad=DIR     Initialize alternate directory at start

Any additional options will be passed to fzf.
USAGE
}

for arg in "$@"; do
  case $arg in
    -h|--help) usage; exit 0 ;;
    -r|--recursive) unset SHALLOW; shift ;;
    -sf=*|--shallow-find=*) SHALLOW_FIND="${arg#*=}"; shift ;;
    -rf=*|--recursive-find=*) RECURSIVE_FIND="${arg#*=}"; shift ;;
    -bd=*|--base-dir=*|--base_directory=*) BASE_DIR="${arg#*=}"; shift ;;
    -ad=*|--alt-dir=*|--alternate-directory=*) ALT_DIR="${arg#*=}"; shift ;;
    # Save remaining options for fzf with quoting preserved
    -*) OPTS+=("${arg%%=*}=\"${arg#*=}\""); shift ;;
  esac
done

# Derive base directory from target argument,
# or use current directory if none given
if [[ -z "$BASE_DIR" ]]; then
  [[ -d "$1" ]] && BASE_DIR="$1" || BASE_DIR="$(dirname "${1:-$PWD/.}")"
fi
pushd "$BASE_DIR" && pushd +1 >/dev/null

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
  FZF="fzf --multi --layout='reverse' --expect='$KEYS' --prompt='${PWD#$BASE_DIR}>' ${OPTS[@]}"
  { read command; mapfile -t targets; } < <(bash -c "$FIND" | bash -c "$FZF")

  # Use Escape or ctrl-c to exit
  [[ "${#targets[@]}" -eq 0 ]] && break

  case $command in
    # Use alt-a to toggle showing "all" nested files/directories
    # vs. only those at top-level
    alt-a)
      [[ $SHALLOW ]] && unset SHALLOW || SHALLOW=1
      targets=()
    ;;

    # Use ctrl-r to move targets
    ctrl-r)
      read -ep 'Move to Directory: ' -i "${ALT_DIR:-$BASE_DIR}" DIR
      [[ -n "$DIR" ]] && mv -i "${targets[@]}" "$DIR"
      targets=()
    ;;

    # Use alt-r to rename targets
    alt-r)
      for t in "${targets[@]}"; do
        if [[ -r "$t" ]]; then
          read -ep 'Move/Rename File: ' -i "mv $t ${ALT_DIR:-.}/$t" RENAME
          [[ -n "$RENAME" ]] && bash -c "$RENAME"
        fi
      done
      targets=()
    ;;

    # Use ctrl-x to delete targets
    ctrl-x)
      REMOVE="rm -rI ${targets[@]}"
      bash -c "$REMOVE"
      targets=()
    ;;

    # Use alt-x to move and rename targets
    alt-x)
      read -ep 'Move/Rename to Directory: ' -i "${ALT_DIR:-$BASE_DIR}" DIR
      if [[ -n "$DIR" ]]; then
        for t in "${targets[@]}"; do
          if [[ -r "$t" ]]; then
            read -ep 'Move/Rename File: ' -i "mv $PWD/$t $DIR/$t" MVRENAME
            [[ -n "$MVRENAME" ]] && bash -c "$MVRENAME"
          fi
        done
      fi
      targets=()
    ;;

    # Use ctrl-s to copy/save targets
    ctrl-s)
      read -ep 'Copy to Directory: ' -i "${ALT_DIR:-$BASE_DIR}" DIR
      [[ -n "$DIR" ]] && cp -ir "${targets[@]}" "$DIR"
      targets=()
    ;;

    # Use alt-s to copy and rename targets
    alt-s)
      read -ep 'Copy/Rename to Directory: ' -i "${ALT_DIR:-$BASE_DIR}" DIR
      if [[ -n "$DIR" ]]; then
        for t in "${targets[@]}"; do
          if [[ -r "$t" ]]; then
            read -ep 'Copy/Rename File: ' -i "cp $PWD/$t $DIR/$t" RENAME
            [[ -n "$COPY" ]] && bash -c "$COPY"
          fi
        done
      fi
      targets=()
    ;;

    # Use ctrl-d to create and enter directory
    # Use alt-d to create a directory without changing current directory
    ctrl-d|alt-d)
      targets=()
      read -p "Create directory: " target
      if [[ -n "$target" ]]; then
        mkdir -p "$target"
        [[ "$command" = 'ctrl-d' ]] && targets=("$target")
      fi
    ;;

    # Use ctrl-f to create a file and edit it immediately
    # Use alt-f to create a file without editing
    ctrl-f|alt-f)
      targets=()
      read -p "Create file: " target
      if [[ -n "$target" ]]; then
        mkdir -p "$(dirname "$target")" && touch "$target"
        [[ "$command" = 'ctrl-f' ]] && targets=("$target")
      fi
    ;;

    # Use ctrl-space to set base directory
    ctrl-space)
      read -ep "Set base directory: " -i "$BASE_DIR" DIR
      [[ -d "$DIR" ]] && BASE_DIR="$DIR"
      targets=()
    ;;

    # Use alt-space to set alternate directory
    # Use alt-/ to enter alternate directory, or go back
    # to previous directory if already in alternate directory
    alt-space|alt-/)
      if [[ "$command" = 'alt-space' || ! -d "$ALT_DIR" ]]; then
        read -ep "Set alternate directory: " -i "$PWD" DIR
        [[ -d "$DIR" ]] && ALT_DIR="$DIR" || echo "Not a directory"
      fi
      if [[ "$command" = 'alt-/' && -d "$ALT_DIR" ]]; then
        [[ "$PWD" = "$ALT_DIR" ]] && cd "$OLDPWD" || cd "$ALT_DIR"
      fi
      targets=()
    ;;

    # Use alt-b to bookmark targets
    alt-b)
      DIR="$PWD"
      for b in "${targets[@]}"; do
        cd "$DIR/$b"
        [[ ! "$(dirs -l)" =~ " $PWD" ]] && pushd "$PWD" >/dev/null
      done
      targets=()
    ;;

    # Use alt-u to un-bookmark current directory
    alt-u)
      mapfile -t DIRS < <(dirs -p -l)
      for i in "${!DIRS[@]}"; do
        [[ $i -ge 1 && "${DIRS[$i]}" = "$PWD" ]] && popd +$i >/dev/null
      done
      targets=()
    ;;

    # Use alt-up to select bookmarked directory using fzf
    alt-up)
      mapfile -d ' ' -t DIRS < <(dirs -l | tr -d '\n')
      target="$(printf '%s\n' "${DIRS[@]}" | fzf)"
      targets=("$target")
    ;;

    # Use alt-right to go to next bookmarked directory
    alt-right)
      cd "$(dirs -l +1)"
      pushd +1 >/dev/null 
      targets=()
    ;;

    # Use alt-left to go to previous bookmarked directory
    alt-left)
      cd "$(dirs -l -0)"
      pushd -0 >/dev/null 
      targets=()
    ;;

    # Use left arrow to move up a directory (not above base directory)
    left)
      [[ "$PWD" != "$BASE_DIR" ]] && targets=("..") || targets=('.')
    ;;

    # Use enter (parsed as empty string) or right arrow for default action
  esac

  main "${targets[@]}"
}

# Default initial target is current directory
main "$BASE_DIR"
