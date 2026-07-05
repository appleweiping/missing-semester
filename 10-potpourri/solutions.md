# Lecture 10 — Potpourri

Course page: <https://missing.csail.mit.edu/2020/potpourri/>

This lecture is a grab-bag of smaller topics and has **no exercises** on the
course page. For completeness, here are concise, runnable notes on the topics
it covers, several of which reuse tooling built in earlier lectures.

---

### Keyboard remapping
Remap Caps Lock → Escape/Ctrl (huge for Vim). Linux: `setxkbmap` / `xcape`;
macOS: System Settings → Keyboard → Modifier Keys; Windows: PowerToys or
`SharpKeys`. Tools: `xdotool`, `AutoHotkey`.

### Daemons & `systemd`
Background services managed by `systemd`. Inspect with
`systemctl status`, `journalctl -u <unit>`. A user unit lives in
`~/.config/systemd/user/foo.service` and is enabled with
`systemctl --user enable --now foo`. `cron` schedules periodic jobs
(`crontab -e`).

### FUSE (Filesystem in Userspace)
Userspace filesystems: `sshfs` mounts a remote dir over SSH, `rclone mount`
exposes cloud storage as a local folder — both build on FUSE.

### Backups
The 3-2-1 rule: 3 copies, 2 media, 1 offsite. Backups must be **incremental**,
**versioned**, **tested for restore**, and ideally **encrypted**. Tools:
`rsync`, `restic`, `borg`. (Ties into the security lecture: encrypt before
uploading.)

### APIs & authentication
Most web services expose JSON REST APIs; query them with `curl` and slice with
`jq` (used in the data-wrangling lecture). OAuth gives a token instead of
sharing a password. `IFTTT`/webhooks glue services together.

### Common command-line flags/patterns
`--help`/`man`, `--version`, `-` for stdin/stdout, `--` to end option parsing,
`--dry-run`/`-n`, `--verbose`/`-v`, `-i` interactive, `-r`/`-R` recursive.

### Window/terminal managers & multiplexers
Tiling WMs (i3, xmonad) and `tmux` (configured in
[`../dotfiles/.tmux.conf`](../dotfiles/.tmux.conf)) keep the hands on the
keyboard.

### Markdown
The lightweight markup used for every `solutions.md` in this repo.

### Hammerspoon / booting / VMs / containers
macOS desktop automation (Hammerspoon/Lua); the BIOS→bootloader→kernel boot
chain; virtual machines vs. containers (Docker) for reproducible, isolated
environments.
