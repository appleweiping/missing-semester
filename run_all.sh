#!/usr/bin/env bash
# run_all.sh — run every auto-verifiable exercise in the repo and report
# pass/fail, writing per-lecture logs into results/.
#
# Usage:
#   PYTHON=/path/to/python bash run_all.sh
# On this repo's dev box:
#   PYTHON="D:/Project/_csdiy/.venv-ml/Scripts/python.exe" \
#   PATH="D:/devtools/bin:$PATH" bash run_all.sh
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

PY="${PYTHON:-python}"
pass=0; fail=0
run() {
    local name="$1"; shift
    printf '\n>>> %s\n' "$name"
    if "$@"; then echo "    [PASS] $name"; pass=$((pass+1));
    else echo "    [FAIL] $name"; fail=$((fail+1)); fi
}

# Ensure the data-wrangling dictionary is present.
bash scripts/get_words.sh >/dev/null 2>&1 || true

run "01 course-shell"           bash 01-course-shell/solve.sh
run "02 ex1 fancy-ls"           bash 02-shell-tools/ex1_ls.sh .
run "02 ex3 run-until-fail"     bash 02-shell-tools/ex3_rununtilfail.sh bash -c 'exit 1'
run "02 ex5 newest-file"        bash 02-shell-tools/ex5_newest.sh .
run "04 ex2 words"              bash 04-data-wrangling/ex2_words.sh
run "04 ex3 in-place sed"       bash 04-data-wrangling/ex3_inplace.sh
run "04 ex4/5 boot sample"      bash 04-data-wrangling/ex4_ex5_sample.sh
run "05 job control"            bash 05-command-line/ex_jobcontrol.sh
run "05 aliases"                bash 05-command-line/ex_aliases.sh
run "06 ex4 git stash"          bash 06-version-control/ex4_stash.sh
run "06 ex3 scrub history"      bash 06-version-control/ex3_remove_sensitive.sh
run "07 ex2 pdb demo"           "$PY" 07-debugging-profiling/ex2_pdb_demo.py
run "07 ex5 profile sorts"      "$PY" 07-debugging-profiling/profile_sorts.py
run "07 ex6 fib callgraph"      "$PY" 07-debugging-profiling/fib_callgraph.py
run "09 ex1 entropy"            "$PY" 09-security/ex1_entropy.py
run "09 ex2 hash verify"        bash 09-security/ex2_hash.sh
run "09 ex3 symmetric AES"      bash 09-security/ex3_symmetric.sh

printf '\n=================== SUMMARY ===================\n'
printf 'passed: %d   failed: %d\n' "$pass" "$fail"
[ "$fail" -eq 0 ] && echo "ALL VERIFIABLE EXERCISES PASSED" || echo "SOME EXERCISES FAILED"
exit "$fail"
