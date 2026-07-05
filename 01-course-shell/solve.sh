#!/usr/bin/env bash
# 01 — Course Overview + The Shell : runnable walkthrough of exercises 1–11.
# Reproduces every step and prints what each one demonstrates.
# Run:  bash solve.sh
set -uo pipefail

hr() { printf '\n=== %s ===\n' "$1"; }

hr "Ex1: which shell am I using?"
echo "\$SHELL = ${SHELL:-<unset in this environment>}"
echo "actual interpreter: $(ps -p $$ -o comm= 2>/dev/null || echo bash)"

hr "Ex2-4: create /tmp/missing and touch a file 'semester'"
mkdir -p /tmp/missing
cd /tmp/missing || exit 1
touch semester
ls -l semester

hr "Ex5: write the two-line script (single quotes so # and ! are literal)"
echo '#!/bin/sh' > semester
echo 'curl --head --silent https://missing.csail.mit.edu' >> semester
cat semester

hr "Ex6: try ./semester before it is executable -> Permission denied"
# We expect this to fail; capture the error instead of aborting.
if ./semester 2>err.txt; then
    echo "(unexpectedly ran)"
else
    echo "failed as expected: $(cat err.txt)"
fi
echo "permissions were: $(ls -l semester | awk '{print $1}')  (no x bits)"

hr "Ex7: run via 'sh semester' -> works because sh reads the file as input"
sh semester | head -n 3
echo "...(sh does not need the execute bit; it just reads the file)"

hr "Ex8-9: chmod +x then run ./semester directly (shebang is used)"
chmod +x semester
echo "permissions now: $(ls -l semester | awk '{print $1}')"
./semester | head -n 3
echo "...the kernel reads the '#!/bin/sh' shebang and runs /bin/sh on the file"

hr "Ex10: pipe + redirect the last-modified header into ~/last-modified.txt"
./semester | grep -i '^last-modified:' > "$HOME/last-modified.txt"
echo "wrote $HOME/last-modified.txt:"
cat "$HOME/last-modified.txt"

hr "Ex11: read a value from /sys (Linux). On Windows/macOS there is no /sys."
if [ -d /sys ]; then
    # e.g. current display brightness or battery capacity if present
    for p in /sys/class/power_supply/BAT0/capacity \
             /sys/class/backlight/*/brightness; do
        [ -r "$p" ] && echo "$p = $(cat "$p")"
    done
    echo "(if nothing printed, this machine exposes no such node)"
else
    echo "/sys not present on this platform (documented in solutions.md)."
fi

hr "done"
