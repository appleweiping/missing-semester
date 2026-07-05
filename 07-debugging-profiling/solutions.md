# Lecture 7 — Debugging and Profiling

Course page: <https://missing.csail.mit.edu/2020/debugging-profiling/>

Python parts use the shared csdiy venv
(`D:\Project\_csdiy\.venv-ml\Scripts\python.exe`, Python 3.11) with
`line_profiler`, `memory_profiler`, `pycallgraph2` installed via `uv`.
Evidence: [`../results/07-debugging-profiling/`](../results/07-debugging-profiling/).

---

## Debugging

### 1. Use `journalctl` on Linux or `log show` on macOS to get the super user accesses and commands in the last day.

Linux-specific; commands and expected output documented in
[`ex1_ex4_ex8_ex9.md`](ex1_ex4_ex8_ex9.md).

### 2. Do this hands on `pdb` tutorial to familiarize yourself with the commands.

Worked through the `pdb` tutorial and applied it to
[`ex2_pdb_demo.py`](ex2_pdb_demo.py), which has a real off-by-one bug
(`range(1, len(xs))` skips the first element → `buggy_sum([10,20,30,40])` gives
**90** instead of **100**). [`ex2_pdb_run.sh`](ex2_pdb_run.sh) drives it under
`python -m pdb` non-interactively using `break`, `continue`, `args`, `p`,
`next` — the captured session in `ex2_pdb.log` shows inspecting `xs`, `total`,
and `i` to localise the bug. `fixed_sum` then matches the builtin `sum()`.

### 3. Install `shellcheck` and try checking the following script. What is wrong with the code? Fix it.

Ran `shellcheck` (v0.10.0) on [`ex3_broken.sh`](ex3_broken.sh) — the exact
buggy m3u-playlist script from the lecture. **Findings:**

| line | code | what's wrong |
|------|------|--------------|
| SC2045 | `for f in $(ls *.m3u)` | parsing `ls` output is fragile — use a glob |
| SC2035 | `*.m3u` | prefix with `./` so a filename can't look like an option |
| SC2062/SC2086 | `grep -qi hq.*mp3 $f` | quote the pattern **and** `"$f"` (spaces/globs) |
| SC2016 | `echo -e '... $f ...'` | `$f` never expands inside single quotes |

[`ex3_fixed.sh`](ex3_fixed.sh) applies all fixes (glob + `nullglob`, quoted
pattern, quoted `"$f"`, `printf`) and passes `shellcheck` **clean** — see
`ex3_shellcheck.log`.

### 4. (Advanced) Read about reversible debugging and get a simple example working using `rr` or RevPDB.

`rr` is Linux/x86-only; the record/replay and `reverse-continue` workflow is
documented in [`ex1_ex4_ex8_ex9.md`](ex1_ex4_ex8_ex9.md).

## Profiling

### 5. ... use `cProfile` and `line_profiler` to compare insertion sort and quicksort. Which function is the bottleneck ...? Then use the `memory_profiler` ... why does insertion sort do better? Check the inplace quicksort ...

[`sorts.py`](sorts.py) + [`profile_sorts.py`](profile_sorts.py) +
[`line_and_memory.py`](line_and_memory.py). **Measured (N=2000, CPU):**

| sort | wall-clock | note |
|------|-----------|------|
| insertion_sort | **161.2 ms** | O(n²) |
| quicksort (allocating) | **5.74 ms** | ~28× faster |
| quicksort_inplace | **4.10 ms** | fastest |

- **Bottleneck (line_profiler):** insertion sort spends ~99% of its time in the
  inner `while` loop (`array[j] > key` 39.5% + the shift `array[j+1]=array[j]`
  35.3% + `j -= 1` 24.8%). Quicksort's cost is the two list-comprehensions
  (40.9% + 42.5%).
- **Memory (memory_profiler):** insertion_sort +0.035 MiB, allocating quicksort
  +0.137 MiB, in-place quicksort ~0 MiB. **Insertion sort wins on memory**
  because it edits one list in place, whereas the allocating quicksort builds
  fresh `left`/`right` lists at every recursion level. The in-place quicksort
  gets both: fast *and* O(1) extra memory.

### 6. Here's some code that runs a simple stopwatch [Fibonacci]. ... use `pycallgraph` and `graphviz` ... How many times is `fib0` called? ... Uncomment the memoization ... how many times does each function get called now?

[`fib_callgraph.py`](fib_callgraph.py). **Measured for fib(20):**

- naive `fib` : **21,891 calls** — equals `2·F(21) − 1`, the exponential blow-up.
- memoized `fib` : **39 calls** — linear. **561× fewer calls.**

A real Graphviz call graph was rendered to
[`../results/07-debugging-profiling/fib_callgraph.png`](../results/07-debugging-profiling/fib_callgraph.png)
(via `pycallgraph2` + a locally-installed Graphviz `dot`), showing `fib_naive`
as the hot node.

### 7. A common issue is that a port you want to listen on is already taken ... run `python -m http.server 4444` ... use `lsof` ... `kill`.

[`ex7_lsof_kill.sh`](ex7_lsof_kill.sh) starts `http.server` on :4444, locates
the listening process (`lsof -iTCP:4444 -sTCP:LISTEN`, or `ss`/`netstat`
fallback), and kills it. Verified on Windows via `netstat -ano` (found PID 6000
holding `0.0.0.0:4444 LISTENING`) and confirmed the port is freed.

### 8. Limit process resources using `taskset`/`stress`/`htop`/`cgroups`.

Linux tools; documented with the exact commands in
[`ex1_ex4_ex8_ex9.md`](ex1_ex4_ex8_ex9.md). The equivalent CPU-affinity concept
was verified locally on Windows (`ProcessorAffinity = 0xFFFF` over 16 logical
CPUs; settable to e.g. `0x5` for cores 0 and 2).

### 9. (Advanced) Sniff `curl ipinfo.io` with Wireshark; filter on `http`.

GUI capture; the `tcpdump`/Wireshark commands and the two expected HTTP packets
(GET request + 200 response) are documented in
[`ex1_ex4_ex8_ex9.md`](ex1_ex4_ex8_ex9.md).
