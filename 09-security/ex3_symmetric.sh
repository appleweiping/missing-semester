#!/usr/bin/env bash
# Ex3: Symmetric cryptography. Encrypt a file with AES-256-CBC using openssl,
# look at the ciphertext, then decrypt and confirm it matches the original.
set -euo pipefail

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cd "$WORK"

PASS="correct horse battery staple"

echo "=== create a plaintext file ==="
cat > secret.txt <<'EOF'
This is a confidential message.
Attack at dawn. Bring coffee.
EOF
echo "plaintext (secret.txt):"; cat secret.txt
echo "sha256(plaintext): $(sha256sum secret.txt | awk '{print $1}')"

echo
echo "=== encrypt with AES-256-CBC (salted) ==="
# -pbkdf2 derives the key from the passphrase properly; -salt randomises output.
openssl enc -aes-256-cbc -salt -pbkdf2 \
    -in secret.txt -out secret.enc -pass "pass:$PASS"
echo "ciphertext (secret.enc), hexdump head:"
od -A x -t x1z secret.enc | head -4
echo "note: the 'Salted__' magic + 8-byte salt prefix the ciphertext."

echo
echo "=== decrypt ==="
openssl enc -d -aes-256-cbc -pbkdf2 \
    -in secret.enc -out decrypted.txt -pass "pass:$PASS"
echo "decrypted (decrypted.txt):"; cat decrypted.txt

echo
echo "=== confirm decrypted == original with cmp ==="
if cmp -s secret.txt decrypted.txt; then
    echo "cmp: decrypted file is IDENTICAL to the original  [OK]"
else
    echo "cmp: FILES DIFFER  [FAIL]"
    exit 1
fi

echo
echo "=== (demo) a wrong passphrase fails to decrypt ==="
if openssl enc -d -aes-256-cbc -pbkdf2 \
    -in secret.enc -out /dev/null -pass "pass:wrong password" 2>/dev/null; then
    echo "decrypted with wrong pass?! (unexpected)"
else
    echo "wrong passphrase correctly rejected (bad decrypt / padding error)"
fi
