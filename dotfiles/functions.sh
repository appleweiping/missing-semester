# functions.sh — marco/polo from the shell-tools lecture (exercise 2)
# Source this from your ~/.bashrc:  [ -f ~/functions.sh ] && . ~/functions.sh

# marco: remember the current working directory.
marco() {
    export MARCO_DIR="$(pwd)"
    echo "marco: saved $MARCO_DIR"
}

# polo: jump back to the directory saved by the last marco.
polo() {
    if [ -z "${MARCO_DIR:-}" ]; then
        echo "polo: no directory saved yet (run marco first)" >&2
        return 1
    fi
    cd "$MARCO_DIR" || return 1
}

# pidwait: block until the process with the given PID exits
# (command-line lecture, job-control exercise 2).
pidwait() {
    local pid="$1"
    if [ -z "$pid" ]; then
        echo "usage: pidwait <pid>" >&2
        return 1
    fi
    # kill -0 sends no signal; it only checks whether the pid exists.
    while kill -0 "$pid" 2>/dev/null; do
        sleep 1
    done
    echo "pidwait: process $pid has finished"
}
