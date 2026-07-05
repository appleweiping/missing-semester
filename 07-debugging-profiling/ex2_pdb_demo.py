"""Ex2: a small buggy function to practise pdb on.

The bug: `buggy_sum` uses `range(1, len(xs))` and so skips the first element.
Drive it under pdb non-interactively to show the commands, or run directly to
see the wrong-then-fixed result.

Interactive session (what you'd type):
    $ python -m pdb ex2_pdb_demo.py
    (Pdb) break buggy_sum          # set a breakpoint
    (Pdb) continue                 # run to it
    (Pdb) args                     # show arguments
    (Pdb) print(list(xs))          # inspect state
    (Pdb) next / step              # step through
    (Pdb) print(total)             # watch the accumulator
    (Pdb) p len(xs)                # evaluate expressions
    (Pdb) continue

A scripted pdb run is produced by ex2_pdb_run.sh and captured in results/.
"""
from __future__ import annotations


def buggy_sum(xs):
    total = 0
    for i in range(1, len(xs)):   # BUG: should start at 0
        total += xs[i]
    return total


def fixed_sum(xs):
    total = 0
    for i in range(0, len(xs)):
        total += xs[i]
    return total


if __name__ == "__main__":
    data = [10, 20, 30, 40]
    print(f"buggy_sum({data}) = {buggy_sum(data)}   (wrong: skips the first 10)")
    print(f"fixed_sum({data}) = {fixed_sum(data)}   (correct)")
    print(f"builtin sum({data}) = {sum(data)}")
    assert fixed_sum(data) == sum(data)
    print("fixed_sum matches builtin sum() -> bug understood and corrected")
