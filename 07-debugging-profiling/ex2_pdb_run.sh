#!/usr/bin/env bash
# Drive ex2_pdb_demo.py under pdb non-interactively, feeding it a scripted set
# of pdb commands, to prove the debugger workflow end-to-end.
set -uo pipefail
PY="${PYTHON:-python}"

"$PY" -m pdb ex2_pdb_demo.py <<'PDB'
break buggy_sum
continue
args
p list(xs)
next
next
p total
p i
continue
p len([10,20,30,40])
continue
PDB
