"""Ex5: profile insertion sort vs quicksort with cProfile + line_profiler +
memory_profiler, and explain the results.

Usage:  python profile_sorts.py
"""
from __future__ import annotations
import cProfile
import io
import pstats

from sorts import insertion_sort, quicksort, quicksort_inplace, make_data


def cprofile_call(func, *args):
    pr = cProfile.Profile()
    pr.enable()
    func(*args)
    pr.disable()
    s = io.StringIO()
    ps = pstats.Stats(pr, stream=s).sort_stats("cumulative")
    ps.print_stats(8)
    return s.getvalue()


def main():
    N = 2000
    data = make_data(N)

    print(f"=== cProfile: insertion_sort on {N} random ints ===")
    print(cprofile_call(insertion_sort, data))

    print(f"=== cProfile: quicksort (allocating) on {N} random ints ===")
    print(cprofile_call(quicksort, list(data)))

    print(f"=== cProfile: quicksort_inplace on {N} random ints ===")
    print(cprofile_call(quicksort_inplace, list(data)))

    # Timing summary with timeit-style repeated runs.
    import timeit
    print("=== wall-clock (best of 3, N=2000) ===")
    for name, stmt in [
        ("insertion_sort", "insertion_sort(d)"),
        ("quicksort", "quicksort(list(d))"),
        ("quicksort_inplace", "quicksort_inplace(list(d))"),
    ]:
        t = min(
            timeit.repeat(
                stmt,
                setup="from sorts import insertion_sort, quicksort, quicksort_inplace, make_data; d=make_data(2000)",
                number=1,
                repeat=3,
            )
        )
        print(f"  {name:<18} {t*1000:8.2f} ms")


if __name__ == "__main__":
    main()
