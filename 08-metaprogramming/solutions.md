# Lecture 8 — Metaprogramming

Course page: <https://missing.csail.mit.edu/2020/metaprogramming/>

The build artifacts (a real matplotlib figure and a pdflatex-compiled paper)
are under [`../results/08-metaprogramming/`](../results/08-metaprogramming/).
The project lives in [`paper/`](paper/); CI workflows are in
[`../.github/workflows/`](../.github/workflows/).

---

### 1. Most makefiles provide a target called `clean`. ... Add a `clean` target ... Have a look at `git ls-files` ... Note that Make targets can be declared "phony" by adding a line with their name.

The [`paper/Makefile`](paper/Makefile) builds `paper.pdf` from `paper.tex` +
`plot.png`, where `plot.png` is generated from `data.dat` by `plot-data.py`.
The **`.PHONY: clean`** target removes every generated file:

```make
.PHONY: all clean
clean:
	rm -f plot.png paper.pdf paper.aux paper.log paper.out ...
```

**Verified** (`make_build.log`): after `make`, `plot.png` (20 KB) and
`paper.pdf` (85 KB, 1 page, figure embedded) exist; after `make clean`, only the
four tracked source files (`Makefile`, `paper.tex`, `plot-data.py`, `data.dat`)
remain. A second `make` with nothing changed prints *"Nothing to be done"*, and
`touch data.dat` correctly rebuilds `plot.png` then `paper.pdf`. `git ls-files`
distinguishes the tracked sources from the generated artifacts that `clean`
deletes.

### 2. Take a look at the various ways to specify version requirements for dependencies in Rust's build system. ... For each one (caret, tilde, wildcard, comparison, and multiple), come up with a use-case ...

Full answer with a use-case per operator in
[`ex2_rust_semver.md`](ex2_rust_semver.md): caret `^1.2.3` (default, ordinary
deps), tilde `~1.2.3` (patch-only), wildcard `1.2.*`, comparison `>=1.2,<1.5`
(explicit validated window), and multiple `>=1.2.3, <1.8, !=1.5.0` (carve out a
known-bad release).

### 3. Git can act as a simple CI system all by itself. In `.git/hooks` inside any git directory, we can put scripts that are executed automatically ... Write a `pre-commit` hook that runs `make paper.pdf` and refuses the commit if the `make` command fails.

[`pre-commit`](pre-commit) runs `make paper.pdf` from the repo root and
`exit 1`s (blocking the commit) if the build fails, else cleans up and
`exit 0`s. Install with
`ln -s ../../08-metaprogramming/pre-commit .git/hooks/pre-commit`.

**Verified both paths** (`precommit_hook.log`):
- valid `paper.tex` → `make` succeeds → hook **allows** the commit (exit 0);
- an undefined LaTeX control sequence injected before `\end{document}` → `make`
  fails → hook **blocks** the commit (exit 1).

### 4. Set up a simple auto-published page using GitHub Pages. Add a GitHub Action to the repository to run `shellcheck` on any shell files in that repository.

Two workflows in [`../.github/workflows/`](../.github/workflows/):

- [`pages.yml`](../.github/workflows/pages.yml) — builds a `_site/` from the
  README + every `solutions.md` and deploys it to **GitHub Pages** on push to
  `main` (`upload-pages-artifact` → `deploy-pages`).
- [`shellcheck.yml`](../.github/workflows/shellcheck.yml) — installs shellcheck
  and lints every `git ls-files '*.sh'` (excluding the intentionally-broken
  `ex3_broken.sh`) at `--severity=warning`.

**Verified locally:** running that exact shellcheck command over the 20 real
scripts in this repo passes clean (`ex3_shellcheck.log` shows the design-broken
script's warnings; the rest are silent).

### 5. Build your own GitHub action to run `proselint` or `write-good` on all the `.md` files ... trigger it ... by opening a PR ...

[`prose.yml`](../.github/workflows/prose.yml) sets up Node, installs
`write-good`, and lints every `git ls-files '*.md'` on push/PR. It reports style
issues (weasel words, passive voice, lexical illusions) without hard-failing,
since prose advice is advisory. Opening a PR with an intentional writing error
(e.g. "very very") would surface it in the Action log.
