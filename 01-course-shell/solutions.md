# Lecture 1 — Course Overview + The Shell

Course page: <https://missing.csail.mit.edu/2020/course-shell/>

Run everything with `bash solve.sh` (output captured in
[`../results/01-course-shell/run.log`](../results/01-course-shell/run.log)).

---

### 1. For this course, you will be using a Unix shell like Bash or ZSH. What shell are you using?

```console
$ echo $SHELL
/usr/bin/bash
```

`$SHELL` is your *login* shell. The shell actually interpreting a script can
differ — check with `ps -p $$ -o comm=`.

### 2. Create a new directory called `missing` under `/tmp`.

```console
$ mkdir -p /tmp/missing
```

### 3. Look up the `touch` program.

```console
$ man touch
```

`touch` updates a file's access/modification timestamps, and creates the file
(empty) if it does not already exist.

### 4. Use `touch` to create a new file called `semester` in `missing`.

```console
$ cd /tmp/missing
$ touch semester
```

### 5. Write the following into that file, one line at a time:

```sh
#!/bin/sh
curl --head --silent https://missing.csail.mit.edu
```

The trick is quoting. `#` starts a comment and `!` triggers history expansion in
interactive Bash, so **single quotes** keep both literal:

```console
$ echo '#!/bin/sh' > semester
$ echo 'curl --head --silent https://missing.csail.mit.edu' >> semester
```

`>` truncates then writes; `>>` appends.

### 6. Try to execute the file, i.e. type the path `./semester` into your shell and press enter. Understand why it doesn't work.

On a real Unix box a freshly-`touch`ed file has mode `-rw-r--r--` (no execute
bit), so the shell refuses:

```
bash: ./semester: Permission denied
```

**Platform note (honest):** this repo was verified on Windows (MSYS2/Git-Bash).
Windows has no Unix permission model, so MSYS2 reports every file as
`-rwxr-xr-x` and `./semester` runs immediately — the "Permission denied" step
cannot be reproduced here. On Linux/macOS you get the denial exactly as
described. The `run.log` therefore shows the command succeeding on this host;
the *explanation* (missing `x` bit) is what the exercise is teaching.

### 7. Run the command by explicitly starting the `sh` interpreter, i.e. type `sh semester`. Why does this work, while `./semester` didn't?

```console
$ sh semester
```

`sh semester` works even without the execute bit because you are *not* asking
the kernel to execute the file. You are running the already-executable program
`sh` and handing it the file **as an argument to read**. Read permission is all
that's needed. In contrast, `./semester` asks the kernel to `execve()` the file
directly, which requires the execute bit.

### 8. Look up the `chmod` program.

```console
$ man chmod
```

`chmod` changes a file's permission bits (read/write/execute for
user/group/other).

### 9. Use `chmod` to make it possible to run the command `./semester` rather than having to type `sh semester`.

```console
$ chmod +x semester
$ ./semester
```

Now the file has its execute bit set. When you run `./semester`, the kernel
reads the first line — the **shebang** `#!/bin/sh` — and executes `/bin/sh` with
the file as input. That is how the shebang tells the OS which interpreter to
use.

### 10. Use `|` and `>` to write the "last modified" date output by `semester` into a file called `last-modified.txt` in your home directory.

```console
$ ./semester | grep -i '^last-modified:' > ~/last-modified.txt
$ cat ~/last-modified.txt
Last-Modified: Tue, 09 Jun 2026 16:44:33 GMT
```

`|` pipes `semester`'s stdout into `grep`, which keeps only the `Last-Modified`
header line; `>` redirects that into the file.

### 11. Write a command that reads out your laptop battery's power level or your desktop CPU's temperature from `/sys`. (Note: if you're a macOS user, your OS doesn't have `/sys`.)

On Linux:

```console
$ cat /sys/class/power_supply/BAT0/capacity       # battery %
$ cat /sys/class/thermal/thermal_zone0/temp       # CPU temp (milli-°C)
$ cat /sys/class/backlight/*/brightness           # screen brightness
```

`/sys` is a virtual filesystem the kernel exposes so hardware state looks like
plain files you can `cat`. macOS and Windows have no `/sys`; the script detects
its absence and says so instead of pretending.
