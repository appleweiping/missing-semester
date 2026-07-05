# Lecture 6 — Version Control (Git)

Course page: <https://missing.csail.mit.edu/2020/version-control/>

Evidence: [`../results/06-version-control/`](../results/06-version-control/).

---

### 1. If you don't have any past experience with Git, either try reading the first couple chapters of Pro Git or go through a tutorial like Learn Git Branching. As you're working through it, relate Git commands to the data model.

Worked through *Learn Git Branching* and Pro Git ch. 2–3. The mental model used
throughout: a commit is a **snapshot** (a tree of blobs) plus parent
pointer(s); branches/tags/HEAD are just movable **refs** into that DAG;
`add` stages into the index, `commit` freezes the index into a new snapshot.

### 2. Clone the repository for the class website. (a) Explore the version history by visualizing it as a graph. (b) Who was the last person to modify `README.md`? (c) What was the commit message associated with the last modification to the `collections:` line of `_config.yml`?

Run [`ex2_history.sh`](ex2_history.sh), which clones
`github.com/missing-semester/missing-semester` live. **Measured results:**

- **(a)** `git log --all --graph --decorate --oneline` renders the merge DAG
  (see `ex2.log`).
- **(b)** README.md was last modified by **Anish Athalye
  `<me@anishathalye.com>`** in commit `49f676c` — *"Tweak text about license"*.
  Found with `git log -1 -- README.md`.
- **(c)** The `collections:` line of `_config.yml` (line 19) was last changed in
  commit **`a88b4ea`** — *"Redo lectures as a collection"* (Anish Athalye, Jan
  17 2020). Found with `git blame -L 19,19 _config.yml` → `git show`.

### 3. One common mistake when learning Git is to commit large files that should not be managed by Git or adding sensitive information. Try adding a file to a repository, making some commits and then deleting that file from history (you may want to look at this).

Run [`ex3_remove_sensitive.sh`](ex3_remove_sensitive.sh). It commits a
`secrets.env` across the middle of a three-commit history, confirms it's
present, then scrubs it from **all** history with
`git filter-branch --index-filter 'git rm --cached --ignore-unmatch secrets.env'`,
expires the reflog and `gc`s. **Result:** `secrets.env` no longer appears in any
commit; only `app.py` remains. In real life prefer `git filter-repo
--path secrets.env --invert-paths` or the BFG, force-push, and **rotate the
leaked credential** — deletion from history does not un-leak it.

### 4. Clone some repository from GitHub, and modify one of its existing files. What happens when you do `git stash`? What do you see when running `git log --all --oneline`? Run `git stash pop` to undo what you did with `git stash`. In what scenario might this be useful?

Run [`ex4_stash.sh`](ex4_stash.sh). Modifying `file.txt` then `git stash`
reverts the working tree to the committed state; `git log --all --oneline`
reveals the stash commits (`WIP on …`, `index on …`) that back the
`stash@{0}` ref; `git stash pop` reapplies the diff and drops the stash.
**Useful when** you need to pull, switch branches, or bisect with
half-finished work in progress — park it, do the thing, un-park it.

### 5. Like many command line tools, Git provides a configuration file (or dotfile) called `~/.gitconfig`. Create an alias in `~/.gitconfig` so that when you run `git graph`, you get the output of `git log --all --graph --decorate --oneline`.

Committed in [`../dotfiles/.gitconfig`](../dotfiles/.gitconfig):

```ini
[alias]
    graph = log --all --graph --decorate --oneline
```

Verified: `git config --get alias.graph` returns the expansion, and running the
alias on a scratch repo renders the graph (see `ex5_ex6.log`).

### 6. You can define global ignore patterns in `~/.gitignore_global` after running `git config --global core.excludesfile ~/.gitignore_global`. Do this, and set up your global gitignore file to ignore OS-specific or editor-specific temporary files, like `.DS_Store`.

Committed [`../dotfiles/.gitignore_global`](../dotfiles/.gitignore_global)
(covers `.DS_Store`, `Thumbs.db`, `*.swp`, `.vscode/`, …) and wired up via
`core.excludesfile = ~/.gitignore_global` in `.gitconfig`. Verified with
`git config --get core.excludesfile`.

### 7. Fork the repository for the class website, find a typo or some way to improve the website, and submit a pull request on GitHub (please only submit meaningful PRs).

This step asks for a genuinely useful contribution to the upstream site, which
should only be opened when a real improvement is found (the course explicitly
says *"please only submit meaningful PRs"*). The mechanics — `gh repo fork
missing-semester/missing-semester --clone`, branch, edit, `gh pr create` — are
documented here rather than opening a low-value PR against the live course
repository.
