# The Missing Semester — Worked Exercises

> Genuine, runnable solutions to the exercises of every lecture in
> **MIT's "The Missing Semester of Your CS Education"** — an independent,
> from-scratch build that is part of a [csdiy.wiki](https://csdiy.wiki/) full-catalog effort.

![status](https://img.shields.io/badge/status-complete-brightgreen)
![shell](https://img.shields.io/badge/bash-informational)
![python](https://img.shields.io/badge/python-3.11-informational)
![license](https://img.shields.io/badge/license-MIT-blue)

## Overview

The [Missing Semester](https://missing.csail.mit.edu/) teaches the tools every
programmer is expected to know but no class covers: the shell, scripting, Vim,
data wrangling, the command-line environment, Git internals, debugging &
profiling, build systems / CI, and cryptography. This repo contains **worked,
verified solutions to the exercises** of all nine 2020 lectures (plus notes for
Potpourri), organised one directory per lecture with a `solutions.md` and
runnable scripts, together with a small **dotfiles** set. Every automatable
exercise was actually executed on this machine and its output captured under
[`results/`](results/).

## Results (measured on Windows, Git-Bash + Python 3.11, CPU)

`bash run_all.sh` runs every auto-verifiable exercise: **17/17 pass**
([`results/run_all.log`](results/run_all.log)). Selected measured numbers:

| Lecture | Exercise | Result (measured) |
|---|---|---|
| 01 Shell | 1–11 walkthrough | live `curl` to missing.csail.mit.edu, `Last-Modified` captured |
| 02 Shell tools | marco/polo, run-until-fail, zip-html, newest-file | all verified; spaces-in-filenames handled |
| 03 Vim | XML→JSON via macro/`:s` | headless Vim output passes `jq` validation |
| 04 Data wrangling | words with ≥3 `a`s, no `'s` | **833 words**; top endings `an`(101)/`ns`(63)/`ia`(51); 110 distinct, 566 never occur |
| 04 Data wrangling | World Bank dataset | World pop 6.16B→7.85B (2000→2020), 248 rows, single `awk` stats |
| 05 Command-line | job control, aliases | sleep killed by name (no PID); top cmd `git`×16 |
| 06 Git | history of class repo | README last by **Anish Athalye** (`49f676c`); `collections:` line → `a88b4ea` "Redo lectures as a collection" |
| 06 Git | scrub secret from history | `secrets.env` removed from all commits, verified |
| 07 Debug/profile | insertion vs quicksort | **161 ms vs 5.7 ms vs 4.1 ms** (N=2000); inner loop is 99% of insertion time |
| 07 Debug/profile | fib(20) call counts | naive **21,891** vs memoized **39** calls (561×); real Graphviz call graph |
| 07 Debug/profile | shellcheck | all real bugs flagged; fixed script passes clean |
| 08 Metaprogramming | Makefile paper.pdf | real **matplotlib figure + pdflatex PDF** built; `clean` + incremental rebuild verified |
| 08 Metaprogramming | pre-commit hook | allows good build (exit 0), blocks broken LaTeX (exit 1) |
| 09 Security | password entropy | passphrase **66.4 bits** vs 8-char **47.6 bits** |
| 09 Security | AES-256-CBC | openssl round-trip, `cmp` identical, wrong-pass rejected |
| 09 Security | GPG-signed git | signed commit **and** tag both `git verify-*` → "Good signature" |

**Figure produced by the build pipeline** (lecture 7, fib call graph, and
lecture 8, the paper's plot) live in
[`results/07-debugging-profiling/fib_callgraph.png`](results/07-debugging-profiling/fib_callgraph.png)
and [`results/08-metaprogramming/paper.pdf`](results/08-metaprogramming/paper.pdf).

## Implemented lectures

- [x] **01 — Course Overview + The Shell** (exercises 1–11)
- [x] **02 — Shell Tools and Scripting** (exercises 1–5)
- [x] **03 — Editors (Vim)** (exercises 1–8, incl. headless macro XML→JSON)
- [x] **04 — Data Wrangling** (exercises 1–6, sed/awk/regex over real data)
- [x] **05 — Command-line Environment** (job control, aliases, tmux, ssh)
- [x] **06 — Version Control (Git)** (exercises 1–7, real repo archaeology)
- [x] **07 — Debugging and Profiling** (exercises 1–9)
- [x] **08 — Metaprogramming** (Make, semver, pre-commit hook, CI workflows)
- [x] **09 — Security and Cryptography** (exercises 1–4)
- [x] **10 — Potpourri** (notes; the lecture has no exercises)
- [x] **dotfiles/** — bash, aliases, vim, git, tmux + an idempotent installer

## Project structure

```
missing-semester/
├── 01-course-shell/ … 10-potpourri/   # one dir per lecture: solutions.md + scripts
├── dotfiles/                          # .bashrc .aliases .vimrc .gitconfig .tmux.conf + install.sh
├── scripts/get_words.sh               # fetches the dictionary used by lecture 4
├── results/                           # captured output of every verified run
├── .github/workflows/                 # shellcheck, prose-lint, and Pages CI (lecture 8)
├── run_all.sh                         # runs & checks all auto-verifiable exercises
├── requirements.txt
└── LICENSE
```

## How to run

```bash
# Shell/CLI exercises need bash (Git-Bash on Windows) + coreutils.
# Python exercises use the shared csdiy env (Python 3.11):
#   D:\Project\_csdiy\.venv-ml\Scripts\python.exe
uv pip install --python <python> -r requirements.txt   # matplotlib + profilers

# Fetch the dictionary used by the data-wrangling lecture:
bash scripts/get_words.sh

# Run and verify EVERYTHING:
PYTHON=<python> bash run_all.sh          # -> 17/17 pass

# Or run a single lecture, e.g.:
bash 04-data-wrangling/ex2_words.sh
python 07-debugging-profiling/profile_sorts.py

# Install the dotfiles into your $HOME (backs up existing files first):
bash dotfiles/install.sh
```

External tools some exercises use (documented where needed): `jq`, `shellcheck`,
`openssl`, `gpg`, `vim`, `make`, `pdflatex` (for the metaprogramming PDF), and
`graphviz`'s `dot` (for the call-graph PNG).

## Verification

- **`run_all.sh` → 17/17 auto-verifiable exercises pass**
  ([`results/run_all.log`](results/run_all.log)).
- Each lecture's `solutions.md` links to the exact captured log(s) under
  `results/<lecture>/`.
- Real, non-mocked verifications include: a live `curl` to the course site;
  `jq`-validated Vim macro output; sed/awk pipelines over the genuine 99,170-word
  dictionary and the live World Bank population dataset; `git blame`/`git show`
  archaeology on the actual class-website repository; `cProfile`/`line_profiler`/
  `memory_profiler` numbers; a Graphviz-rendered call graph; a `make`-built
  matplotlib+LaTeX PDF; and **GPG-signed Git commits/tags that pass
  `git verify-commit`/`git verify-tag`**.
- Platform-specific exercises (Linux `journalctl`/`taskset`/`rr`, VM-based SSH
  steps, GUI Wireshark) are documented with exact commands and, where possible,
  a verified portable equivalent — clearly marked, never faked.

## Tech stack

Bash / POSIX shell, `sed`/`awk`/`grep`/`find`/`xargs`, Vim, Git, `openssl`,
`gpg`, GNU Make + LaTeX, and Python 3.11 (`matplotlib`, `line_profiler`,
`memory_profiler`, `pycallgraph2`). GitHub Actions for CI.

## Key ideas / what I learned

- The shell as a composable, pipe-driven programming environment; robust
  scripting (`set -euo pipefail`, NUL-delimited `find -print0 | xargs -0`).
- Text wrangling as data engineering: regex + `sed`/`awk` to turn logs and
  dictionaries into answers in one line.
- Git's snapshot-and-refs data model, and archaeology (`log`/`blame`/`show`/
  `stash`) plus history rewriting to remove secrets.
- Profiling to find the *actual* bottleneck (line-level) and the time/memory
  trade-off between algorithms.
- Build systems as dependency graphs, and Git hooks + GitHub Actions as CI.
- Practical cryptography: entropy math, hashes for integrity, symmetric vs
  asymmetric encryption, and signed commits for authenticity.

## Credits & license

Based on the exercises of **The Missing Semester of Your CS Education** by
Anish Athalye, Jon Gjengset, and Jose Javier Gonzalez Ortiz (MIT). This
repository is an independent educational reimplementation; all course materials
and specifications belong to their original authors. Original code here is
released under the [MIT License](LICENSE).
