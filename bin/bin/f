#!/bin/bash

# This provides a shorthand for finding files using regular expression search.
# It takes query and path as the last two parameters so this can serve as a
# fallback for the 'fd' command. (https://github.com/sharkdp/fd)

# Use current directory as default path if script is invoked with one parameter
[[ $# -eq 1 ]] && set -- "$@" '.'

# Fail if too few parameters
if [[ $# -lt 2 ]]; then
  echo "USAGE: f [optional-flags] [pattern] [path]" 1>&2
  exit 1
fi

# Capture options, then regex query, then finally the search path
[[ $# -ge 3 ]] && opts="${@:1:$[$# - 2]}"
query="${@:$[$# - 1]:1}"
path="${@:$#:1}"

# Ignore hidden files, unless this script was invoked as 'fh' (find hidden)
noDots=1
[[ $(basename $0) = 'fh' ]] && unset noDots

# Call 'find' using reordered/optional parameters
find "$path" ${noDots:+ -not -path '*/\.*'} -iregex ".*$query.*" ${opts:+ $opts}

