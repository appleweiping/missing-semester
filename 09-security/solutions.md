# Lecture 9 — Security and Cryptography

Course page: <https://missing.csail.mit.edu/2020/security/>

Evidence: [`../results/09-security/`](../results/09-security/). All keys are
generated in throwaway temp dirs — nothing is left on the host.

---

### 1. Entropy. (a) How many bits of entropy is a password made up of four random common words (from a dictionary of size 100,000)? (b) An 8-character password chosen at random from a-z, A-Z, 0-9? (c) Which is stronger? (d) Assuming an attacker can try 10,000 guesses per second, roughly how long would it take to crack each?

[`ex1_entropy.py`](ex1_entropy.py). Entropy = `log2(search space)`. **Measured
(at 10,000 guesses/sec, average = half the space):**

| password | search space | entropy | avg crack time |
|----------|-------------|---------|----------------|
| **(a)** four words / 100k dict | `100000⁴ = 1e20` | **66.4 bits** | ~1.6×10⁸ years |
| **(b)** 8-char alphanumeric | `62⁸ = 2.2e14` | **47.6 bits** | ~346 years |

**(c)** The **four-word passphrase is stronger** (66.4 vs 47.6 bits) — an extra
~19 bits ≈ 500,000× larger search space, which is the whole point of the
"correct horse battery staple" argument. (Both dwarf 10k guesses/sec; the gap
matters against fast offline attacks.)

### 2. Cryptographic hash functions. Download a Debian image from a mirror and cross-check its integrity by comparing the hash of what you downloaded with the hash from the Debian website.

[`ex2_hash.sh`](ex2_hash.sh) runs the identical **verification workflow** on a
small stand-in file (to keep the repo fast): compute the SHA-256, compare
against the "published" value → **MATCH**; then flip a single byte → the hash
changes completely (`cb0675d0…` → `86fdd7d9…`), demonstrating the **avalanche
effect** that makes tampering detectable. The verbatim Debian commands
(`curl` the ISO + `SHA256SUMS`, then `sha256sum -c SHA256SUMS`) are included at
the end of the script output.

### 3. Symmetric cryptography. Encrypt a file with AES encryption, using OpenSSL: `openssl aes-256-cbc -salt -in {input filename} -out {output filename}`. Look at the contents using `cat` or `hexdump`. Decrypt it with `openssl aes-256-cbc -d -in {input filename} -out {output filename}` and confirm that the contents match the original using `cmp`.

[`ex3_symmetric.sh`](ex3_symmetric.sh). **Verified round-trip:**

- Encrypt `secret.txt` with `openssl enc -aes-256-cbc -salt -pbkdf2`. The
  `hexdump` shows the ciphertext begins with the `Salted__` magic + 8-byte salt
  (`53 61 6c 74 65 64 5f 5f …`).
- Decrypt and `cmp -s secret.txt decrypted.txt` → **IDENTICAL**.
- A **wrong passphrase** is correctly rejected (bad-decrypt/padding error).

(`-pbkdf2` is added over the lecture's bare command because modern OpenSSL warns
about the old key-derivation; the crypto is otherwise exactly as asked.)

### 4. Asymmetric cryptography. (a) Set up SSH keys ... (b) Set up GPG. (c) Send Anish an encrypted email (public key online). (d) Sign a Git commit with `git commit -S` or create a signed Git tag with `git tag -s` and verify the signature with `git verify-commit` or `git verify-tag`.

[`ex4_asymmetric.sh`](ex4_asymmetric.sh). **Verified end-to-end:**

- **(a)** `ssh-keygen -t ed25519 -a 100` with a passphrase — private key is
  encrypted at rest; fingerprint printed.
- **(b)** Generated a GPG ed25519/cv25519 key pair (`gpg --batch
  --generate-key`) in a throwaway `GNUPGHOME`.
- **(d)** Made a **GPG-signed commit** (`git commit -S`) and a **signed tag**
  (`git tag -s`); both `git verify-commit HEAD` and `git verify-tag v1.0`
  report **"Good signature"**. See `ex4_asymmetric.log`.
- **(c)** Sending an encrypted email uses the recipient's public key:
  `gpg --encrypt --armor -r recipient@example.com message.txt` — documented
  (needs a real recipient key + mail client, so not auto-run).
