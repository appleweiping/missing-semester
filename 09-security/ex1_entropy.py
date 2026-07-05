#!/usr/bin/env python3
"""Ex1: password entropy.

(a) bits of entropy of a passphrase = four words chosen randomly from a
    100,000-word dictionary.
(b) bits of entropy of an 8-character alphanumeric (a-z A-Z 0-9) password.
(c) which is stronger?
(d) at 10,000 guesses/second, how long on average to crack each?

Entropy of an independently-chosen sequence is log2(choices_per_symbol) summed
over the symbols; equivalently log2(total_search_space).
"""
from __future__ import annotations
import math


def bits(space: float) -> float:
    return math.log2(space)


def human_time(seconds: float) -> str:
    units = [("year", 365 * 24 * 3600), ("day", 24 * 3600),
             ("hour", 3600), ("minute", 60), ("second", 1)]
    for name, size in units:
        if seconds >= size:
            return f"{seconds / size:,.1f} {name}s"
    return f"{seconds:.2g} seconds"


def main():
    GUESSES_PER_SEC = 10_000

    # (a) four words from a 100,000-word dictionary
    dict_size = 100_000
    n_words = 4
    space_a = dict_size ** n_words
    entropy_a = bits(space_a)  # = 4 * log2(100000)

    # (b) 8 chars from [a-zA-Z0-9] = 62 symbols
    alphabet = 26 + 26 + 10
    n_chars = 8
    space_b = alphabet ** n_chars
    entropy_b = bits(space_b)  # = 8 * log2(62)

    print("=== (a) four random words from a 100,000-word dictionary ===")
    print(f"  search space = 100000^4 = {space_a:.3e}")
    print(f"  entropy      = 4*log2(100000) = {entropy_a:.1f} bits")

    print("\n=== (b) 8-character alphanumeric password ===")
    print(f"  search space = 62^8 = {space_b:.3e}")
    print(f"  entropy      = 8*log2(62) = {entropy_b:.1f} bits")

    print("\n=== (c) which is stronger? ===")
    stronger = "passphrase (a)" if entropy_a > entropy_b else "alphanumeric (b)"
    print(f"  {entropy_a:.1f} bits vs {entropy_b:.1f} bits -> {stronger} is stronger")

    print("\n=== (d) average crack time at 10,000 guesses/sec ===")
    # On average you search half the space before hitting the right one.
    for label, space in [("(a) passphrase", space_a), ("(b) alphanumeric", space_b)]:
        avg_guesses = space / 2
        secs = avg_guesses / GUESSES_PER_SEC
        print(f"  {label:<18} {human_time(secs)}")


if __name__ == "__main__":
    main()
