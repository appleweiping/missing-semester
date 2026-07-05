"""Ex5 continued: line_profiler (per-line timing) and memory_profiler
(per-line memory) on the sorts, to explain WHERE the time/memory goes and why
insertion sort — despite being slower — uses less memory than the allocating
quicksort.

Usage:  python line_and_memory.py
"""
from __future__ import annotations

from line_profiler import LineProfiler
from memory_profiler import memory_usage

from sorts import insertion_sort, quicksort, quicksort_inplace, make_data


def line_profile():
    data = make_data(1500)
    lp = LineProfiler()
    lp.add_function(insertion_sort)
    lp.add_function(quicksort)
    wrapped = lp(lambda: (insertion_sort(data), quicksort(list(data))))
    wrapped()
    lp.print_stats()


def memory_profile():
    data = make_data(3000)
    print("=== peak memory (MiB) via memory_profiler.memory_usage ===")
    for name, call in [
        ("insertion_sort", lambda: insertion_sort(data)),
        ("quicksort (allocating)", lambda: quicksort(list(data))),
        ("quicksort_inplace", lambda: quicksort_inplace(list(data))),
    ]:
        usage = memory_usage(call, interval=0.001, max_iterations=1)
        print(f"  {name:<24} peak +{max(usage) - min(usage):6.3f} MiB "
              f"(baseline {min(usage):.1f})")
    print()
    print("Insertion sort sorts a single list in place (O(1) extra memory),")
    print("while the allocating quicksort builds fresh left/right lists at every")
    print("level of recursion (O(n log n) extra memory). That is insertion")
    print("sort's advantage: lower memory footprint despite worse time.")


if __name__ == "__main__":
    line_profile()
    memory_profile()
