#!/bin/bash
set -x

# This provides a shorthand for finding files using regular expression search.
# Swaps query and path to be the last parameters so this can serve as a
# fallback for the 'fd' command. (https://github.com/sharkdp/fd)

echo "called as: $(basename $0)"

# Fail if too few parameters
if [[ $# -lt 2 ]]; then
  echo "USAGE: f [optional-flags] [pattern] [path]" 1>&2
  exit 1
fi

[[ $# -ge 3 ]] && rest="${@:1:$[$# - 2]}"
query="${@:$[$# - 1]:1}"
path="${@:$#:1}"

noHidden=1
[[ $(basename $0) = 'fh' ]] && unset noHidden

find "$path" ${noHidden:+  -not -path '*/\.*'} -iregex ".*$query.*" ${rest:+ $rest}

