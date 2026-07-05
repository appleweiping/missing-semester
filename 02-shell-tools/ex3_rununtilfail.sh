#!/usr/bin/env bash
# Ex3: run the given command repeatedly until it fails, capturing stdout+stderr,
# and print the captured output plus the number of attempts it took to fail.
#
# Usage:  ./ex3_rununtilfail.sh <command> [args...]
# Example: ./ex3_rununtilfail.sh bash -c 'echo attempt; (( RANDOM % 5 ))'
set -u

if [ "$#" -eq 0 ]; then
    echo "usage: $0 <command> [args...]" >&2
    exit 2
fi

out="$(mktemp)"
err="$(mktemp)"
# Clean up temp files on exit no matter how we leave.
trap 'rm -f "$out" "$err"' EXIT

count=0
while true; do
    count=$((count + 1))
    # Capture this run's stdout and stderr separately.
    "$@" >"$out" 2>"$err"
    status=$?
    if [ "$status" -ne 0 ]; then
        echo "command failed after $count attempt(s) with exit code $status"
        echo "----- captured STDOUT -----"
        cat "$out"
        echo "----- captured STDERR -----"
        cat "$err"
        exit 0
    fi
done
