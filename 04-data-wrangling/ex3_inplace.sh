#!/usr/bin/env bash
# Ex3: Why is `sed 's/REGEX/SUB/' input.txt > input.txt` a bad idea?
# Demonstrate the data-loss, then show the correct in-place approaches.
set -uo pipefail

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cd "$work" || exit 1

printf 'hello world\nfoo bar\nhello again\n' > input.txt
echo "=== original input.txt ==="
cat input.txt

echo
echo "=== the WRONG way:  sed '...' input.txt > input.txt ==="
echo "The shell opens (and truncates) input.txt for '>' BEFORE sed starts"
echo "reading it. sed then reads an already-empty file. Result: data lost."
# Reproduce it on a copy so we can show the empty result.
cp input.txt bad.txt
sed 's/hello/HELLO/' bad.txt > bad.txt || true
echo "--- bad.txt after the redirect trick (empty!) ---"
cat bad.txt
echo "[bad.txt is $(wc -c < bad.txt) bytes]"

echo
echo "Is this particular to sed?  No — it is the SHELL doing the truncation,"
echo "so the same footgun applies to awk, grep, tr, cat ... any 'cmd f > f'."

echo
echo "=== the RIGHT way #1:  sed -i (in-place, from man sed) ==="
cp input.txt good1.txt
sed -i 's/hello/HELLO/' good1.txt
cat good1.txt

echo
echo "=== the RIGHT way #2:  write to a temp file then move ==="
cp input.txt good2.txt
sed 's/hello/HELLO/' good2.txt > good2.tmp && mv good2.tmp good2.txt
cat good2.txt

echo
echo "Both correct methods preserve all three lines and apply the substitution."
