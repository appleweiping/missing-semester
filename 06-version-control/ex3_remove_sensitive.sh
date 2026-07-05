#!/usr/bin/env bash
# Ex3: try to commit a file that should not be there (a large/secret file),
# then remove it from the history entirely.
#
# We demonstrate the safe modern approach with `git filter-branch` (available
# everywhere). `git filter-repo` / the BFG are the recommended tools in practice;
# the commands for those are noted at the end.
set -uo pipefail

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"
git init -q repo && cd repo
git config user.email t@t; git config user.name t

echo "=== commit some normal files plus a 'secret' file across two commits ==="
echo "public code" > app.py
git add app.py && git commit -q -m "add app"
echo "AWS_SECRET_KEY=hunter2" > secrets.env
git add secrets.env && git commit -q -m "oops, committed secrets.env"
echo "more code" >> app.py
git add app.py && git commit -q -m "more app work"

echo "--- secrets.env IS in history right now ---"
git log --oneline --stat | grep -A1 secrets.env | head
echo "commits that contain secrets.env:"
git log --oneline -- secrets.env

echo
echo "=== scrub secrets.env from ALL of history ==="
git filter-branch --force --index-filter \
    'git rm --cached --ignore-unmatch secrets.env' \
    --prune-empty --tag-name-filter cat -- --all >/dev/null 2>&1

# Also drop the original refs kept as backup by filter-branch, and gc.
rm -rf .git/refs/original/
git reflog expire --expire=now --all >/dev/null 2>&1
git gc --prune=now --quiet 2>&1 | head -1 || true

echo "--- is secrets.env still anywhere in history? ---"
if git log --oneline -- secrets.env | grep -q .; then
    echo "STILL PRESENT (unexpected)"
else
    echo "GONE: no commit references secrets.env any more"
fi
echo "--- working tree ---"; ls
echo
echo "In practice, prefer: git filter-repo --path secrets.env --invert-paths"
echo "or the BFG:          bfg --delete-files secrets.env"
echo "and then force-push. Rotate the leaked credential regardless!"
