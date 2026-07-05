#!/usr/bin/env bash
# Command-line environment — Job Control exercises.
#
# Ex1: background a `sleep 10000`, find it with pgrep, kill it with pkill
#      WITHOUT typing the PID.
# Ex2: pidwait — block until a given PID exits (implemented in
#      ../dotfiles/functions.sh; re-shown and exercised here).
set -uo pipefail

echo "=== Ex1: start sleep 10000 in the background, then pgrep/pkill it ==="
sleep 10000 &
bgpid=$!
echo "started 'sleep 10000' as background job, PID (for reference) = $bgpid"

# In an interactive shell you would background an existing foreground job with
# Ctrl-Z then `bg`. In a script we launch it with '&' directly.
#
# Canonical Linux commands (what the exercise asks for):
#     pgrep -af sleep          # find the PID by name
#     pkill -f 'sleep 10000'   # kill it by name, no PID typed
# This machine's minimal environment may lack procps' pgrep/pkill, so we detect
# them and otherwise emulate the exact same "match by name, no PID typed" idea
# with `ps | grep | kill`.
echo "finding the job by name (pgrep or ps|grep):"
if command -v pgrep >/dev/null 2>&1; then
    pgrep -af 'sleep 10000'
    echo "killing by name with pkill (no PID typed):"
    pkill -f 'sleep 10000' && echo "pkill matched and signalled the process"
else
    echo "(pgrep/pkill absent — using ps | grep | kill, still no PID typed)"
    ps | grep '[s]leep' | awk '{print $1, $NF}'
    # kill every matching process by name, without ever typing a literal PID.
    # `[s]leep` in the grep pattern prevents grep from matching its own process.
    ps | grep '[s]leep' | awk '{print $1}' | xargs -r kill 2>/dev/null \
        && echo "matched sleep process(es) killed by name"
fi

# Confirm it is gone.
sleep 0.3
if kill -0 "$bgpid" 2>/dev/null; then
    echo "still alive (unexpected)"
else
    echo "confirmed: the sleep process is gone"
fi

echo
echo "=== Ex2: pidwait — wait for a process to finish ==="
# Reuse the library implementation.
source "$(dirname "$0")/../dotfiles/functions.sh"
sleep 3 &
target=$!
echo "spawned 'sleep 3' with PID $target; pidwait will block until it exits..."
time pidwait "$target"
