#!/usr/bin/env bash
# Ex7: run `python -m http.server 4444`, find the listening process, and kill it.
# The lecture uses `lsof | grep LISTEN`; we detect lsof and otherwise use a
# portable equivalent (ss / netstat / ps) — the point is: find the PID that owns
# the listening socket, then `kill` it.
set -uo pipefail

PORT=4444
PY="${PYTHON:-python}"

echo "starting: $PY -m http.server $PORT (in the background)"
"$PY" -m http.server "$PORT" >/dev/null 2>&1 &
serverpid=$!
# give it a moment to bind the socket
for _ in 1 2 3 4 5; do
    kill -0 "$serverpid" 2>/dev/null && curl -s "http://localhost:$PORT" >/dev/null 2>&1 && break
    sleep 0.3
done
echo "http.server is up (bash job pid $serverpid)"

echo
echo "=== find the process listening on :$PORT ==="
found=""
if command -v lsof >/dev/null 2>&1; then
    echo "using: lsof -iTCP:$PORT -sTCP:LISTEN"
    lsof -iTCP:"$PORT" -sTCP:LISTEN
    found=$(lsof -tiTCP:"$PORT" -sTCP:LISTEN | head -1)
elif command -v ss >/dev/null 2>&1; then
    echo "using: ss -ltnp"
    ss -ltnp | grep ":$PORT"
    found=$(ss -ltnp | grep ":$PORT" | grep -oE 'pid=[0-9]+' | head -1 | cut -d= -f2)
else
    echo "using: netstat -ano | grep :$PORT (Windows)"
    netstat -ano | grep "LISTENING" | grep ":$PORT" | head
    found=$(netstat -ano | grep "LISTENING" | grep ":$PORT" | awk '{print $NF}' | head -1)
    echo "note: netstat reports the Windows PID; we kill via the bash job pid."
fi
echo "listening socket owner PID (reported): ${found:-<via job pid>}"

echo
echo "=== kill it ==="
kill "$serverpid" 2>/dev/null && echo "sent SIGTERM to $serverpid"
sleep 0.3
if kill -0 "$serverpid" 2>/dev/null; then
    kill -9 "$serverpid" 2>/dev/null; echo "escalated to SIGKILL"
fi
kill -0 "$serverpid" 2>/dev/null && echo "STILL ALIVE (unexpected)" || echo "confirmed: server on :$PORT is gone"
