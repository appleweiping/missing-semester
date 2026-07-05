# Lecture 4 — Data Wrangling

Course page: <https://missing.csail.mit.edu/2020/data-wrangling/>

The dictionary used by exercise 2 is fetched at runtime by
[`../scripts/get_words.sh`](../scripts/get_words.sh) into `data/words`
(it is `.gitignore`d). Evidence: [`../results/04-data-wrangling/`](../results/04-data-wrangling/).

---

### 1. Take this short interactive regex tutorial.

Completed <https://regexone.com/> — all 15 lessons plus the practice problems
(matching phone numbers, emails, HTML tags, file names, trimming whitespace,
capture groups, and back-references). Key take-aways used throughout this
lecture: `.` any char, `\d \w \s` classes, `*+?` quantifiers, `{m,n}` counts,
anchors `^ $`, groups `( )`, alternation `|`, and back-references `\1`.

### 2. Find the number of words (in `/usr/share/dict/words`) that contain at least three `a`s and don't have a `'s` ending. What are the three most common last two letters of those words? How many of those two-letter combinations are there? And, for a challenge, which combinations do not occur?

Run [`ex2_words.sh`](ex2_words.sh). **Measured against the real 99,170-word
dictionary:**

```
words with >=3 a's and no "'s" ending : 833
three most common last-two-letters    : an (101), ns (63), ia (51)
distinct two-letter endings           : 110
two-letter endings that never occur   : 566  (ab, af, ai, aj, ao, ap, aq, ...)
```

Pipeline: `grep -iE "^([^a]*a){3}"` requires three `a`s, `grep -v "'s$"` drops
possessives, `tr 'A-Z' 'a-z'` normalises case, `grep -oE '..$'` grabs the last
two letters, and `sort | uniq -c | sort -rn` ranks them. The "never occur" set
is `comm -23` of *all* `aa..zz` against the observed endings.

### 3. To do in-place substitution it is quite tempting to do something like `sed s/REGEX/SUBSTITUTION/ input.txt > input.txt`. However this is a bad idea, why? Is this particular to `sed`? Use `man sed` to find out how to accomplish this.

Run [`ex3_inplace.sh`](ex3_inplace.sh). **Why it's bad:** the *shell* sets up
the `>` redirection **before** `sed` runs, and `>` truncates the target file to
zero length immediately. So by the time `sed` opens `input.txt` to read it, the
file is already empty — you get an empty output and the original is gone. The
script reproduces this: `bad.txt` ends up **0 bytes**.

**Is it particular to `sed`?** No. The truncation is done by the shell's `>`,
so `cmd input.txt > input.txt` destroys data for *any* `cmd` (awk, grep, tr…).

**Correct approaches** (from `man sed`):
- `sed -i 's/REGEX/SUB/' input.txt` — GNU in-place edit (BSD needs `-i ''`).
- `sed 's/…/…/' in > tmp && mv tmp in` — write to a temp file, then rename.

Both preserve all lines, verified in `ex3.log`.

### 4. Find the average, median, and max system boot time over the last ten boots. (`journalctl` on Linux and `log show` on macOS)

`journalctl` is Linux-only; this machine is Windows. The exact command is in
[`ex4_ex5_boot.md`](ex4_ex5_boot.md), and the **pipeline shape is verified**
against `sample_boot.log`:

```
boots=3  avg=8.47s  max=9.10s  median=8.42s
```

(`grep -oE 'Startup finished in [0-9.]+s'` → `sort -n` → an `awk` that computes
avg/median/max in one pass.)

### 5. Look for boot messages that are not shared between your past three reboots.

Also in [`ex4_ex5_boot.md`](ex4_ex5_boot.md) / `ex4_ex5_sample.sh`. Strip the
per-line timestamp/PID, `uniq -c` to count occurrences across the three boots,
then `awk '$1 != 3'` to keep only the messages that did **not** appear in all
three. Verified: the shared `kernel version` and `Graphical Interface` lines
are dropped, while the per-boot wifi/bluetooth/startup-time lines remain.

### 6. Find an online data set... Fetch it using `curl`, extract two columns of numerical data, compute the min and max of one column, and the difference of the sum of each column.

Run [`ex6_dataset.sh`](ex6_dataset.sh). It `curl`s the **World Bank total
population** dataset (17,196 rows) and pivots it to a two-column table of
*year-2000 vs year-2020* population per country/region. **Measured:**

```
World population 2000 = 6,161,884,811   2020 = 7,854,748,424
rows (country/region pairs)             = 248
min of column-1 (year 2000)             = 9,544        (a micro-territory)
max of column-1 (year 2000)             = 6,161,884,811 (the "World" aggregate)
sum(col2) - sum(col1)                   = 18,735,473,074
```

Each statistic is produced by a single `awk` pipeline. A committed
`data/population_sample.csv` provides an offline fallback if the fetch fails.
