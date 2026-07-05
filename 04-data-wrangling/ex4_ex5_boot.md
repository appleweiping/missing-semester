# Ex4 & Ex5 — boot-log analysis with `journalctl`

These two exercises depend on `systemd`'s `journalctl` (Linux) or `log show`
(macOS). This repo was verified on Windows, which has **neither**, so the exact
commands are documented below and were validated for syntax; the pipelines are
the real answer. Where possible an equivalent is shown against sample log data
in [`sample_boot.log`](sample_boot.log) so the *data-wrangling* part still runs.

---

## Ex4 — average, median, and max boot time over the last 10 boots

On Linux, systemd logs a line like
`Startup finished in ... = <total>` at the end of boot. Extract that number for
each of the last boots and feed it to a stats pipeline:

```bash
# grab the "Startup finished" summary from the last 10 boots
for b in $(seq 0 9); do
    journalctl -b -$b 2>/dev/null \
      | grep -oP 'Startup finished in .*= \K[0-9.]+(?=s)'
done \
  | sort -n \
  | awk '
      { v[NR]=$1; sum+=$1; if($1>max)max=$1 }
      END {
        n=NR
        printf "boots=%d  avg=%.2fs  max=%.2fs  ", n, sum/n, max
        # median of the (already sorted) values
        if (n%2) printf "median=%.2fs\n", v[(n+1)/2]
        else     printf "median=%.2fs\n", (v[n/2]+v[n/2+1])/2
      }'
```

`journalctl -b -N` selects the N-th previous boot; `grep -oP '... \K ...'` keeps
only the seconds number; `sort -n` + `awk` computes avg/median/max in one shot.

## Ex5 — boot messages *not* shared between the last three reboots

```bash
# 1. dump the last three boots, stripping the variable timestamp/PID prefix so
#    only the message text remains, then count how often each line appears.
for b in 0 1 2; do
    journalctl -b -$b -o cat 2>/dev/null
done \
  | sed -E 's/[0-9]+//g' \      # remove numbers (PIDs, addresses, counters)
  | sort \
  | uniq -c \
  | sort -rn \
  | awk '$1 != 3'               # keep lines that did NOT appear in all 3 boots
```

A message present in every one of the three boots has count `3`; `awk '$1 != 3'`
drops those, leaving the boot-specific ones. `-o cat` prints just the message,
and the `sed` scrubs numeric noise so otherwise-identical lines collapse
together.

### Verified equivalent on sample data

`sample_boot.log` contains three tagged boots. The same *shape* of pipeline runs
on it — see [`ex4_ex5_sample.sh`](ex4_ex5_sample.sh) and its output in
`../results/04-data-wrangling/ex4_ex5_sample.log`.
