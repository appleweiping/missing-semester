#!/usr/bin/env bash
# Command-line environment — Aliases exercises.
#
# Ex1: alias `dc` to `cd` (common typo).
# Ex2: use the history one-liner to find your 10 most-used commands.
set -uo pipefail

echo "=== Ex1: alias dc='cd' ==="
# Aliases only take effect in interactive shells; define and prove it here.
shopt -s expand_aliases
alias dc='cd'
cwd_before=$(pwd)
dc /tmp
echo "after 'dc /tmp' we are in: $(pwd)  (dc behaved exactly like cd)"
cd "$cwd_before" || exit 1
echo "This alias lives permanently in ../dotfiles/.bashrc."

echo
echo "=== Ex2: 10 most frequently used commands from history ==="
# The lecture's one-liner. `history` is only populated in interactive shells,
# so demonstrate the exact pipeline on a representative sample history file.
sample_hist="$(dirname "$0")/sample_history.txt"
echo "(running the pipeline on sample_history.txt for a reproducible result)"
awk '{print $1}' "$sample_hist" \
  | sort | uniq -c | sort -rn | head -n 10

cat <<'NOTE'

The exact interactive command from the lecture is:
  history | awk '{$1="";print substr($0,2)}' | sort | uniq -c | sort -n | tail -n 10
(use `history 1` on ZSH). Good alias candidates from a typical history:
  git -> g,  git status -> gs,  git commit -> gc, etc. (see ../dotfiles/.bashrc)
NOTE
