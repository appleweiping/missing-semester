#!/usr/bin/env bash
# Ex4: recursively find all HTML files in a folder and pack them into a single
# zip archive, correctly handling filenames that contain spaces/newlines.
#
# Usage:  ./ex4_ziphtml.sh <folder> [output.zip]
#
# The key correctness point: `find -print0` + `xargs -0` use NUL as the
# separator, so spaces and newlines in filenames don't split arguments.
set -euo pipefail

folder="${1:?usage: $0 <folder> [output.zip]}"
archive="${2:-html_files.zip}"

# Remove a stale archive so we start clean.
rm -f -- "$archive"

# -type f  regular files only
# -iname   case-insensitive match on *.html and *.htm
find "$folder" -type f \( -iname '*.html' -o -iname '*.htm' \) -print0 \
    | xargs -0 zip -q "$archive"

echo "created $archive:"
unzip -l "$archive"
