#!/usr/bin/env bash
# Ex4: Asymmetric cryptography.
#   (a) generate an SSH key pair with a passphrase.
#   (b) set up GPG (generate a key).
#   (c) [documented] send a GPG-encrypted email using a recipient's public key.
#   (d) make a signed git commit/tag and verify the signature.
#
# This script performs (a), (b) and (d) end-to-end in a throwaway GNUPGHOME so it
# leaves no keys on the host. (c) requires a real recipient key + mail client and
# is documented in solutions.md.
set -euo pipefail

WORK="$(mktemp -d)"
export GNUPGHOME="$WORK/gnupg"
mkdir -p "$GNUPGHOME"; chmod 700 "$GNUPGHOME"
trap 'gpgconf --kill all 2>/dev/null || true; rm -rf "$WORK"' EXIT

echo "=== (a) generate an SSH key pair (ed25519, with passphrase) ==="
ssh-keygen -t ed25519 -a 100 -f "$WORK/id_ed25519" -N "a-strong-passphrase" -q
echo "public key: $(cat "$WORK/id_ed25519.pub")"
echo "fingerprint: $(ssh-keygen -lf "$WORK/id_ed25519.pub")"
echo "the PRIVATE key is encrypted at rest with the passphrase (openssl/bcrypt KDF)."

echo
echo "=== (b) set up GPG — generate an unattended key ==="
cat > "$WORK/keyparams" <<'EOF'
%no-protection
Key-Type: eddsa
Key-Curve: ed25519
Subkey-Type: ecdh
Subkey-Curve: cv25519
Name-Real: Missing Semester
Name-Email: missing@example.com
Expire-Date: 0
%commit
EOF
gpg --batch --generate-key "$WORK/keyparams" 2>&1 | grep -iE 'key|revocation' | head -3
KEYID=$(gpg --list-secret-keys --with-colons | awk -F: '/^sec:/{print $5; exit}')
echo "generated GPG key id: $KEYID"

echo
echo "=== (d) make a SIGNED git commit and tag, then verify ==="
GIT_DIR_REPO="$WORK/repo"
git init -q "$GIT_DIR_REPO"
cd "$GIT_DIR_REPO"
git config user.name "Missing Semester"
git config user.email "missing@example.com"
git config gpg.program "$(command -v gpg)"
git config user.signingkey "$KEYID"

echo "hello signed world" > file.txt
git add file.txt
git commit -q -S -m "signed commit"
git tag -s v1.0 -m "signed tag v1.0"

echo "--- git log --show-signature ---"
git log --show-signature -1 2>&1 | grep -iE 'Good signature|gpg|commit' | head -4
echo "--- git verify-commit HEAD ---"
git verify-commit HEAD 2>&1 | grep -i 'Good signature' && echo "commit signature: VERIFIED"
echo "--- git verify-tag v1.0 ---"
git verify-tag v1.0 2>&1 | grep -i 'Good signature' && echo "tag signature: VERIFIED"

echo
echo "(c) sending an encrypted email is documented in solutions.md:"
echo "    gpg --encrypt --armor -r recipient@example.com message.txt"
