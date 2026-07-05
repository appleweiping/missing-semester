#!/usr/bin/env bash
# Run the Ex4/Ex5 pipeline SHAPES against sample_boot.log so the data-wrangling
# logic is verified even without a real systemd journal.
set -euo pipefail
LOG="$(dirname "$0")/sample_boot.log"

echo "=== Ex4: avg / median / max 'Startup finished' time across the 3 boots ==="
grep -oE 'Startup finished in [0-9.]+s' "$LOG" \
  | grep -oE '[0-9.]+' \
  | sort -n \
  | awk '
      { v[NR]=$1; sum+=$1; if($1>max)max=$1 }
      END {
        n=NR
        printf "boots=%d  avg=%.2fs  max=%.2fs  ", n, sum/n, max
        if (n%2) printf "median=%.2fs\n", v[(n+1)/2]
        else     printf "median=%.2fs\n", (v[n/2]+v[n/2+1])/2
      }'

echo
echo "=== Ex5: messages NOT shared by all three boots ==="
# Strip the BOOTn tag and the HH:MM:SS timestamp, keep the message, count it,
# and drop lines that appear in all three boots (count == 3).
sed -E 's/^BOOT[0-9]+ [0-9:]+ //' "$LOG" \
  | sort \
  | uniq -c \
  | sort -rn \
  | awk '$1 != 3 { $1=""; sub(/^ /,""); print }'
