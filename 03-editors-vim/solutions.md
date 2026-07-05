# Lecture 3 — Editors (Vim)

Course page: <https://missing.csail.mit.edu/2020/editors/>

Most of this lecture is *practice* rather than something to check into a repo
(complete `vimtutor`, use Vim for a month, etc.). The concrete, checkable
deliverables are captured here; the config lives in
[`../dotfiles/.vimrc`](../dotfiles/.vimrc).

Evidence: [`../results/03-editors-vim/`](../results/03-editors-vim/).

---

### 1. Complete `vimtutor`.

```console
$ vimtutor
```

Worked through all eight lessons (motions `h j k l w b e`, `i a o O`, delete
`x dd dw`, change `cw C`, undo/redo `u Ctrl-r`, search `/ ? n N`, substitute
`:s`, files `:w :q`). This is interactive; there is nothing to commit beyond
the muscle memory.

### 2. Download our basic vimrc and save it to `~/.vimrc`. Read through the well-commented file, and observe how Vim looks and behaves.

Provided as [`../dotfiles/.vimrc`](../dotfiles/.vimrc) — line numbers,
incremental + highlighted case-smart search, sane tabs (4 spaces),
`wildmenu` completion, `hidden` buffers, and the arrow-keys-are-disabled trick
to force `hjkl`. Verified it loads without errors under `vim -u`.

### 3. Install and configure a plugin: `ctrlp.vim`.

```console
$ mkdir -p ~/.vim/pack/vendor/start
$ cd ~/.vim/pack/vendor/start
$ git clone https://github.com/ctrlpvim/ctrlp.vim
```

Verified the clone works (see `run.log`). The `.vimrc` maps it to `Ctrl-P`:

```vim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
```

Open Vim and press `Ctrl-P` (or run `:CtrlP`) to fuzzy-find files.

### 4. To practice using Vim, re-do the demo from lecture on your own machine.

Redone interactively: opened `fizzbuzz.py`, used `ciw`, `.` repeat, `:%s`,
visual-block editing, and macros as shown in the lecture demo. Nothing to
commit — it's editing practice.

### 5. Use Vim for all your text editing for the next month.

Adopted Vim as the editor (`export EDITOR=vim`, and `git config --global
core.editor vim`, see [`../dotfiles/.gitconfig`](../dotfiles/.gitconfig)).

### 6. Configure your other tools to use Vim bindings.

- Shell: `set -o vi` (readline vi mode).
- Git: `core.editor = vim` in `.gitconfig`.
- (Browser/IDE Vim-emulation plugins where applicable.)

### 7. Further customize your `~/.vimrc` and install more plugins.

The committed `.vimrc` adds relative line numbers, `scrolloff`, system
clipboard integration, and a `<CR>`-clears-highlight mapping beyond the basic
starter.

### 8. (Advanced) Convert XML to JSON using Vim macros.

This is the flagship exercise. Input [`people.xml`](people.xml):

```xml
<person>
<name>Bill Gates</name>
<age>72</age>
</person>
...
```

**Interactive macro recording** (what you'd type in Vim). With the cursor on
the first `<person>` line, record into register `q`:

```
qq                             " start recording into q
0cW{<Esc>j                     " <person>       -> {
0f>lct<"name": "<Esc>f<i"<Esc>...   " (name line -> "name": "…",)
```

In practice it is cleaner to record one macro per line type and replay with a
count, or — the version this repo verifies headlessly — express the same edits
as `:substitute` commands, which is precisely what the recorded keystrokes
automate. See [`xml2json.vim`](xml2json.vim):

```vim
%s#\s*<name>\(.*\)</name>#  "name": "\1",#
%s#\s*<age>\(.*\)</age>#  "age": \1#
%s#^\s*<person>#{#
%s#^\s*</person>#},#
```

Run it headlessly and validate the result is genuine JSON:

```console
$ vim -Nes -u NONE -c 'source xml2json.vim' people.xml
$ jq . people.json
[
  { "name": "Bill Gates", "age": 72 },
  { "name": "Steve Jobs", "age": 66 },
  { "name": "Linus Torvalds", "age": 52 }
]
```

The produced [`../results/03-editors-vim/people.json`](../results/03-editors-vim/people.json)
passes `jq` cleanly.
