# Lecture 2 — Shell Tools and Scripting

Course page: <https://missing.csail.mit.edu/2020/shell-tools/>

Evidence: [`../results/02-shell-tools/run.log`](../results/02-shell-tools/run.log).

---

### 1. Read `man ls` and write an `ls` command that lists files in the following manner: includes all files (including hidden), sizes listed in human-readable format, files ordered by recency, output colorized.

See [`ex1_ls.sh`](ex1_ls.sh):

```bash
ls -lahtr --color=auto
```

| flag | effect |
|------|--------|
| `-l` | long listing (perms, owner, group, size, date, name) |
| `-a` | include hidden dotfiles |
| `-h` | human-readable sizes (`1.0K`, `234M`) |
| `-t` | sort by modification time |
| `-r` | reverse — so the newest file ends up at the bottom |
| `--color=auto` | colourise by file type |

### 2. Write bash functions `marco` and `polo`. `marco` should save the current directory, and `polo`, no matter what directory you're in, should `cd` back to the directory where you executed `marco`.

Implemented in [`../dotfiles/functions.sh`](../dotfiles/functions.sh):

```bash
marco() { export MARCO_DIR="$(pwd)"; echo "marco: saved $MARCO_DIR"; }
polo()  { cd "${MARCO_DIR:?run marco first}"; }
```

`MARCO_DIR` is exported so it survives into subshells. Verified:

```
marco: saved /tmp
wandered to /usr/bin
polo returned to /tmp
```

### 3. Write a bash script that runs a command until it fails, then captures its standard output and error streams to files, and prints everything at the end. Bonus: report how many runs it took.

See [`ex3_rununtilfail.sh`](ex3_rununtilfail.sh). It loops calling `"$@"`,
redirects stdout/stderr to two `mktemp` files, and stops on the first non-zero
exit — printing the run count and both captured streams. Example driver:

```bash
./ex3_rununtilfail.sh bash -c 'echo "hello from attempt"; test $((RANDOM % 4)) -ne 0'
```

`trap 'rm -f "$out" "$err"' EXIT` guarantees the temp files are cleaned up.

### 4. Write a command that recursively finds all HTML files in a folder and makes a zip with them. Note that your command should work even if the files have spaces.

See [`ex4_ziphtml.sh`](ex4_ziphtml.sh):

```bash
find "$folder" -type f \( -iname '*.html' -o -iname '*.htm' \) -print0 \
    | xargs -0 zip -q "$archive"
```

The correctness trick is `-print0` / `xargs -0`: NUL is used as the record
separator, so filenames containing **spaces or newlines** are never split into
multiple arguments. Verified against `a page.html` and `sub dir/b.htm` — both
landed in the archive intact. (GNU `find` is used here; BSD/macOS `find` also
supports `-print0`.)

### 5. (Advanced) Write a command or script to recursively find the most recently modified file in a directory. More generally, can you list all files by recency?

See [`ex5_newest.sh`](ex5_newest.sh):

```bash
find "$dir" -type f -printf '%T@ %p\n' | sort -rn        # newest first
```

`%T@` is the file's modification time as a Unix epoch (with fractional
seconds), so a numeric reverse sort puts the newest file first. `head -n1`
gives the single most-recent file; `--list` prints the whole tree ordered by
recency. Verified: `newest.txt` > `mid.txt` > `old.txt`.
