# Lecture 5 — Command-line Environment

Course page: <https://missing.csail.mit.edu/2020/command-line/>

Evidence: [`../results/05-command-line/`](../results/05-command-line/).

---

## Job Control

### 1. From what we have seen, we can use some `ps aux | grep` commands to get our jobs' pids and then kill them, but there are better ways to do it. Start a `sleep 10000` job in a terminal, background it with `Ctrl-Z` and continue its execution with `bg`. Now use `pgrep` to find its pid and `pkill` to kill it without ever typing the pid itself. (Hint: use the `-af` flags.)

Interactively:

```console
$ sleep 10000
^Z            # suspend
$ bg          # resume in the background
$ pgrep -af sleep
$ pkill -f 'sleep 10000'
```

Verified in [`ex_jobcontrol.sh`](ex_jobcontrol.sh). This machine's minimal
Git-Bash lacks procps' `pgrep`/`pkill`, so the script detects that and uses the
equivalent `ps | grep '[s]leep' | awk '{print $1}' | xargs kill` — matching by
**name**, never typing a PID. Result:

```
1870 /usr/bin/sleep
matched sleep process(es) killed by name
confirmed: the sleep process is gone
```

### 2. Say you don't want to start a process until another completes. How would you go about it? ... write a bash function called `pidwait` that takes a pid and waits until the given process completes.

Implemented in [`../dotfiles/functions.sh`](../dotfiles/functions.sh):

```bash
pidwait() {
    local pid="$1"
    while kill -0 "$pid" 2>/dev/null; do   # kill -0 = "does it exist?"
        sleep 1
    done
    echo "pidwait: process $pid has finished"
}
```

`kill -0` sends **no** signal — it only checks whether the PID still exists — so
the loop polls once a second (cheap) until the process is gone. Verified: it
blocked for ~3s on a `sleep 3` and then returned.

## Terminal Multiplexer (tmux)

Completed the tmux tutorial. A customised config is committed at
[`../dotfiles/.tmux.conf`](../dotfiles/.tmux.conf): `C-a` prefix, `|`/`-` splits
that keep the current path, vim-style `hjkl` pane navigation, mouse mode, 10k
scrollback, and a status bar. Core commands practised: `tmux new -s work`,
`C-a c` (new window), `C-a "` / `C-a %` (split), `C-a d` (detach),
`tmux attach -t work`.

## Aliases

### 1. Create an alias `dc` that resolves to `cd` for when you type it wrongly.

`alias dc='cd'` — committed in [`../dotfiles/.bashrc`](../dotfiles/.bashrc) and
demonstrated in [`ex_aliases.sh`](ex_aliases.sh): `dc /tmp` moved us to `/tmp`.

### 2. Run `history | awk '{$1="";print substr($0,2)}' | sort | uniq -c | sort -n | tail -n 10` to get your top 10 most used commands and consider writing shorter aliases for them.

Run against a representative history in [`ex_aliases.sh`](ex_aliases.sh):

```
16 git
 5 ls
 4 cd
 3 vim
 2 python
```

`git` dominates, so the dotfiles add `gs`, `gl`, `gd`, `..`, `...`, `ll`.

## Dotfiles

Exercises 1–6 are satisfied by the [`../dotfiles/`](../dotfiles/) directory:
a version-controlled set of configs (`.bashrc`, `.aliases`, `.vimrc`,
`.gitconfig`, `.gitignore_global`, `.tmux.conf`, `functions.sh`), an idempotent
[`install.sh`](../dotfiles/install.sh) that back-ups then symlinks them into
`$HOME`, and a customised `$PS1` prompt (with exit-code and git-branch). The
whole set is published as part of this GitHub repo.

## Remote Machines (SSH)

Full command-by-command answers in [`ssh_exercises.md`](ssh_exercises.md). The
two locally-verifiable steps are captured in `results/05-command-line/ssh_verify.log`:
`ssh-keygen -o -a 100 -t ed25519` produces a valid ED25519 key, and `ssh -G vm`
correctly resolves the `Host vm` config block (user, hostname, LocalForward,
IdentityFile). The VM-dependent steps (`ssh-copy-id`, disabling password auth,
mosh, `-N -f` background tunnels) are documented with the exact commands and
their rationale.
