#!/usr/bin/env bash
# Ex5 (advanced): find the most-recently-modified file in a directory tree,
# and (more generally) list all files ordered by recency.
#
# Usage:
#   ./ex5_newest.sh <dir>          # print the single newest file
#   ./ex5_newest.sh <dir> --list   # list all files, newest first
#
# We ask `find` to print "<mtime-epoch> <path>" for every regular file,
# sort numerically descending on the timestamp, then act on the result.
# NUL-free approach with a portable printf format; %T@ is GNU find's epoch mtime.
set -euo pipefail

dir="${1:?usage: $0 <dir> [--list]}"
mode="${2:-newest}"

listing="$(find "$dir" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn)"

if [ "$mode" = "--list" ]; then
    # Strip the leading epoch column for readability.
    echo "$listing" | sed 's/^[0-9.]* //'
else
    # The very first line after a descending sort is the newest file.
    echo "$listing" | head -n1 | sed 's/^[0-9.]* //'
fi
