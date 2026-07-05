#!/usr/bin/env bash
# Ex3: shellcheck-clean version of the buggy script.
#
# Fixes applied (each corresponds to a shellcheck warning on ex3_broken.sh):
#   SC2045: don't parse `ls` — glob directly, and handle the no-match case.
#   SC2086: quote "$f" so filenames with spaces/globs are not split.
#   SC2062/SC2063: quote the grep pattern so the shell/grep don't glob it.
#   SC2039/echo -e: use printf instead of non-portable `echo -e`.
#   SC2016: use double quotes when you WANT $f expanded in the message.
set -euo pipefail

shopt -s nullglob            # a non-matching *.m3u glob expands to nothing

for f in ./*.m3u; do
    if grep -qi 'hq.*mp3' "$f"; then
        printf 'Playlist %s contains a HQ file in mp3 format\n' "$f"
    fi
done
