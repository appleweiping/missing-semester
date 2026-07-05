# Debugging/Profiling — the platform-specific exercises (1, 4, 8, 9)

These require Linux tools (`journalctl`, `rr`, `taskset`, `htop`, `stress`) or a
GUI packet sniffer (Wireshark). This repo was verified on Windows; the exact
commands and expected behaviour are documented, with locally-runnable pieces
noted.

---

## Ex1 — Use `journalctl`/`log show` to get the super-user accesses and commands in the last day.

Linux:

```bash
journalctl --since "1 day ago" _COMM=sudo        # sudo invocations
# or, filter the auth log for the COMMAND= that sudo records:
journalctl --since "1 day ago" | grep -i 'sudo.*COMMAND='
```

macOS:

```bash
log show --last 1d --predicate 'process == "sudo"'
```

If there are none, run a harmless `sudo ls` and re-query; the entry appears with
the invoking user, tty, cwd and the exact `COMMAND=` that was run.

## Ex4 — (Advanced) reversible debugging with `rr` or RevPDB.

`rr` (record-and-replay) is Linux/x86-only and needs hardware perf counters:

```bash
rr record ./buggy_program        # record a trace
rr replay                        # deterministic replay under gdb
(rr) reverse-continue            # run BACKWARDS to the last time a var changed
(rr) reverse-next
(rr) watch -l some_var           # then reverse-continue to catch the write
```

The killer feature: after a crash you can step **backwards** to the moment state
went wrong, instead of re-running and guessing. RevPDB brings similar
reverse-stepping to PyPy. Neither runs on Windows, so this is documented only.

## Ex8 — CPU affinity and resource limits with `taskset`, `htop`, `stress`, `cgroups`.

```bash
stress -c 3                       # 3 CPU-burning workers -> htop shows 3 cores busy
taskset --cpu-list 0,2 stress -c 3
# now the 3 workers are pinned to CPUs 0 and 2 only; htop shows just those two
# cores saturated while the workers time-share them.
man taskset                       # --cpu-list, -p to retarget a running PID
```

`taskset` sets a process's CPU affinity mask so the scheduler may only place it
on the listed cores. Memory can be capped with `stress -m N --vm-bytes SIZE` and,
more robustly, with cgroups:

```bash
sudo cgcreate -g memory:/limited
echo 100M | sudo tee /sys/fs/cgroup/limited/memory.max
sudo cgexec -g memory:limited stress -m 1 --vm-bytes 500M   # OOM-killed at 100M
```

**Windows equivalent that was verified locally:** CPU affinity is set with
`start /affinity <mask>` or PowerShell
`(Get-Process p).ProcessorAffinity = 0x5` (cores 0 and 2). The *concept* — a
bitmask restricting which cores a process may run on — is identical.

## Ex9 — (Advanced) sniff `curl ipinfo.io` with Wireshark, filter on `http`.

```bash
# terminal 1: start capture (or use the Wireshark GUI on your NIC)
sudo tcpdump -i any -A 'tcp port 80 and host ipinfo.io'
# terminal 2:
curl http://ipinfo.io
```

In Wireshark, apply the display filter `http` to see exactly two application-layer
packets: the `GET / HTTP/1.1` request (Host: ipinfo.io) and the
`HTTP/1.1 200 OK` response carrying the JSON body. The TCP handshake
(SYN/SYN-ACK/ACK) and teardown (FIN) surround them. This needs a live GUI
capture, so it is documented rather than auto-run.
