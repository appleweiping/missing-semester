"""Insertion sort and quicksort implementations for the profiling exercise (Ex5).

Two quicksort variants are provided:
  - quicksort:        the simple, allocation-heavy version (list comprehensions)
  - quicksort_inplace: the classic in-place Lomuto-partition version

Run the profiling harness with:  python profile_sorts.py
"""
from __future__ import annotations
import random


def insertion_sort(array):
    """Classic O(n^2) insertion sort. Returns a new sorted list."""
    array = list(array)
    for i in range(1, len(array)):
        key = array[i]
        j = i - 1
        while j >= 0 and array[j] > key:
            array[j + 1] = array[j]
            j -= 1
        array[j + 1] = key
    return array


def quicksort(array):
    """Simple quicksort that allocates new lists each call (readable, wasteful)."""
    if len(array) <= 1:
        return array
    pivot = array[0]
    rest = array[1:]
    left = [x for x in rest if x < pivot]
    right = [x for x in rest if x >= pivot]
    return quicksort(left) + [pivot] + quicksort(right)


def quicksort_inplace(array, lo=0, hi=None):
    """In-place quicksort (Lomuto partition). Sorts `array` in place."""
    if hi is None:
        hi = len(array) - 1
    if lo < hi:
        pivot = array[hi]
        i = lo - 1
        for j in range(lo, hi):
            if array[j] <= pivot:
                i += 1
                array[i], array[j] = array[j], array[i]
        array[i + 1], array[hi] = array[hi], array[i + 1]
        p = i + 1
        quicksort_inplace(array, lo, p - 1)
        quicksort_inplace(array, p + 1, hi)
    return array


def make_data(n, seed=0):
    random.seed(seed)
    return [random.randint(0, 10_000) for _ in range(n)]


if __name__ == "__main__":
    data = make_data(20)
    assert insertion_sort(data) == sorted(data)
    assert quicksort(data) == sorted(data)
    assert quicksort_inplace(list(data)) == sorted(data)
    print("all three sorts agree with sorted()")
