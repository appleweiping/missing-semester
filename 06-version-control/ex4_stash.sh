#!/usr/bin/env bash
# Ex4: clone a repo, modify a file, and see what happens with git stash.
# Run `git log --all --oneline`, then `git stash pop`, and observe.
set -uo pipefail

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"

# Create a tiny local repo (self-contained, no network needed).
git init -q repo && cd repo
git config user.email t@t; git config user.name t
printf 'line one\nline two\n' > file.txt
git add file.txt && git commit -q -m "initial commit"

echo "=== working tree is clean; now modify file.txt ==="
printf 'line one\nMODIFIED line two\nnew line three\n' > file.txt
echo "--- git status ---"; git status --short
echo "--- git diff ---"; git diff

echo
echo "=== git stash — squirrel the changes away ==="
git stash
echo "--- git status after stash (clean) ---"; git status --short
echo "--- file.txt is back to committed state ---"; cat file.txt

echo
echo "=== git log --all --oneline (note the stash refs) ==="
git log --all --oneline
echo "--- git stash list ---"; git stash list

echo
echo "=== git stash pop — restore the changes ==="
git stash pop
echo "--- file.txt has our edits back ---"; cat file.txt
echo
echo "Use case: stash lets you switch branches / pull without committing"
echo "half-finished work, then reapply it afterwards."
