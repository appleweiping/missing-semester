#!/usr/bin/env bash
# Ex2: Cryptographic hash functions. Verify a downloaded file's integrity by
# comparing its SHA-256 against a published hash.
#
# The lecture uses a Debian ISO (~hundreds of MB). To keep this repo fast and
# self-contained we demonstrate the EXACT same integrity-verification workflow
# on a small file whose "official" hash we compute up front, then show that
# tampering flips the check. The Debian commands are shown at the end verbatim.
set -euo pipefail

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"

echo "=== simulate a 'downloaded' file and its published SHA-256 ==="
printf 'debian-12.5.0-amd64-netinst.iso stand-in payload\n' > download.bin
# Pretend this is the checksum published on the official site.
published=$(sha256sum download.bin | awk '{print $1}')
echo "published SHA-256: $published"

echo
echo "=== verify the intact file ==="
actual=$(sha256sum download.bin | awk '{print $1}')
echo "computed SHA-256 : $actual"
if [ "$actual" = "$published" ]; then
    echo "MATCH -> file is authentic and intact  [OK]"
else
    echo "MISMATCH -> reject the file  [FAIL]"; exit 1
fi

echo
echo "=== now tamper with one byte and re-verify ==="
printf 'x' >> download.bin
tampered=$(sha256sum download.bin | awk '{print $1}')
echo "computed SHA-256 : $tampered"
if [ "$tampered" = "$published" ]; then
    echo "still matches?! (a good hash makes this astronomically unlikely)"
else
    echo "MISMATCH detected -> tampering caught by the avalanche effect  [OK]"
fi

cat <<'DEBIAN'

--- The real Debian workflow (verbatim) ---
  # download the image and the checksum file from a mirror
  curl -LO https://cdimage.debian.org/.../debian-12.5.0-amd64-netinst.iso
  curl -LO https://cdimage.debian.org/.../SHA256SUMS
  # verify: this prints "<iso>: OK" if the hash matches the published one
  sha256sum -c SHA256SUMS 2>/dev/null | grep netinst
DEBIAN
