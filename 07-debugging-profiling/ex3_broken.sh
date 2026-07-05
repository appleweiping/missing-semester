#!/usr/bin/env bash
# Ex3: the buggy script from the lecture. Run `shellcheck ex3_broken.sh`.
# The bugs: unquoted $f (word-splitting / globbing on filenames with spaces),
# and reading a loop variable that shadows nothing but is used unquoted.

## Example: create a directory of images, resize them, then remove the originals
mv "$1" "$1.bak"
mkdir "$1"

# Iterate over playlist files
for f in $(ls *.m3u)
do
  grep -qi hq.*mp3 $f \
    && echo -e 'Playlist $f contains a HQ file in mp3 format'
done
