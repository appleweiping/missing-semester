#!/usr/bin/env bash
# Ex2: Clone the repository for the class website and explore its history.
#   (a) visualize the history as a graph
#   (b) who was the last person to modify README.md?
#   (c) what was the commit message for the last change to the `collections:`
#       line of _config.yml?  (hint: git blame + git show)
set -uo pipefail

REPO="https://github.com/missing-semester/missing-semester"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "cloning $REPO ..."
git clone --quiet "$REPO" "$WORK/site" || { echo "clone failed (network)"; exit 1; }
cd "$WORK/site"

echo
echo "=== (a) history as a graph (last 15 commits) ==="
git log --all --graph --decorate --oneline | head -15

echo
echo "=== (b) who last modified README.md ? ==="
# -1 = most recent commit that touched the file.
git log -1 --format='author: %an <%ae>%n date:   %ad%n commit: %h%n subject: %s' -- README.md

echo
echo "=== (c) commit that last changed the 'collections:' line in _config.yml ==="
if [ -f _config.yml ]; then
    # Find the line number of 'collections:' then blame just that line.
    lineno=$(grep -n '^collections:' _config.yml | head -1 | cut -d: -f1)
    if [ -n "${lineno:-}" ]; then
        echo "'collections:' is line $lineno of _config.yml"
        commit=$(git blame -L "${lineno},${lineno}" --porcelain _config.yml | head -1 | awk '{print $1}')
        echo "blamed commit: $commit"
        echo "--- git show of that commit's message ---"
        git show -s --format='%h  %an  %ad%n%s%n%n%b' "$commit"
    else
        echo "no 'collections:' line found (file layout changed); showing blame of the file head:"
        git blame -L 1,5 _config.yml
    fi
else
    echo "_config.yml not present in this checkout"
fi
