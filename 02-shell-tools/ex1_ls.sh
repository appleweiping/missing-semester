#!/usr/bin/env bash
# Ex1: an `ls` invocation that shows
#   - all files (including hidden)
#   - human-readable sizes
#   - sorted by recency (newest last, so the -r reverses the default newest-first)
#   - in colour
#   - with each entry on its own line, permissions/user/group/size/date/name.
#
# Flags used:
#   -l  long listing (permissions, owner, group, size, date, name)
#   -a  all entries, including dotfiles
#   -h  human-readable sizes (1.0K, 234M, ...)
#   -t  sort by modification time
#   -r  reverse the sort (so newest ends up at the bottom)
#   --color=auto  colourise by file type
ls -lahtr --color=auto "$@"
