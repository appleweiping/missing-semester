"""Ex6: profile a recursive Fibonacci with and without memoization, count the
number of calls to each function, and emit a call graph.

The lecture's exercise uses pycallgraph + graphviz. pycallgraph2 (the maintained
fork) is used here; it emits a Graphviz DOT file. If the `dot` binary is
installed it is also rendered to PNG, otherwise the DOT text is the artifact.
We additionally count calls precisely with sys.setprofile, which is the concrete
number the exercise asks for.

Usage:  python fib_callgraph.py
"""
from __future__ import annotations
import sys
from collections import Counter

CALLS = Counter()


def _counter(frame, event, arg):
    if event == "call":
        CALLS[frame.f_code.co_name] += 1
    return _counter


def fib_naive(n):
    if n <= 1:
        return n
    return fib_naive(n - 1) + fib_naive(n - 2)


_memo = {}


def fib_memo(n):
    if n <= 1:
        return n
    if n in _memo:
        return _memo[n]
    _memo[n] = fib_memo(n - 1) + fib_memo(n - 2)
    return _memo[n]


def count_calls(func, n):
    CALLS.clear()
    sys.setprofile(_counter)
    func(n)
    sys.setprofile(None)
    return CALLS.get(func.__name__, 0)


def try_callgraph(n=15):
    """Emit a PNG (and DOT) call graph for fib_naive via pycallgraph2 + Graphviz.

    If the `dot` binary is not on PATH, this falls back to writing just the DOT
    source, which is still a valid, committable artifact.
    """
    import os
    import shutil

    # Allow an explicit Graphviz location so this works even when the binary is
    # installed outside the default PATH (e.g. D:/devtools/graphviz/bin).
    for cand in (os.environ.get("GRAPHVIZ_DOT"),
                 r"D:/devtools/graphviz/bin/dot.exe"):
        if cand and os.path.isfile(cand):
            os.environ["PATH"] = os.path.dirname(cand) + os.pathsep + os.environ["PATH"]
            break

    try:
        from pycallgraph2 import PyCallGraph
        from pycallgraph2.output import GraphvizOutput
    except Exception as e:  # pragma: no cover
        print(f"(pycallgraph2 unavailable: {e})")
        return None

    have_dot = shutil.which("dot") is not None

    out = GraphvizOutput()
    if have_dot:
        out.output_type = "png"
        out.output_file = "fib_callgraph.png"
    else:
        out.output_type = "dot"
        out.output_file = "fib_callgraph.dot"
    try:
        with PyCallGraph(output=out):
            fib_naive(n)
        print(f"wrote call graph to {out.output_file} (fib_naive({n}))")
        return out.output_file
    except Exception as e:
        print(f"(call graph rendering failed, non-fatal: {e})")
        return None


if __name__ == "__main__":
    N = 20
    naive = count_calls(fib_naive, N)
    _memo.clear()
    memo = count_calls(fib_memo, N)
    print(f"=== call counts for fib({N}) ===")
    print(f"  fib_naive : {naive:>6} calls")
    print(f"  fib_memo  : {memo:>6} calls")
    print(f"  speedup in call count: {naive / memo:.1f}x fewer calls")
    print()
    # The closed-form for naive fib call count is 2*F(n+1) - 1.
    print("  (naive call count equals 2*F(n+1) - 1, the exponential blow-up)")
    print()
    try_callgraph(15)
