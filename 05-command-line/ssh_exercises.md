# Remote Machines (SSH) — exercises 1–7

These require a second machine/VM and edits to system files (`sshd_config`),
so they are inherently environment-specific. Below are the exact, correct
commands with explanations. Where a step can be verified locally (key
generation, config parsing) it was.

---

### 1. Go to `~/.ssh/` and check if you have a pair of SSH keys there. If not, generate them with `ssh-keygen -o -a 100 -t ed25519`. It is recommended that you use a passphrase and use `ssh-agent`.

```bash
ls ~/.ssh/                       # look for id_ed25519 / id_ed25519.pub
ssh-keygen -o -a 100 -t ed25519  # -t ed25519: modern curve; -a 100: KDF rounds
eval "$(ssh-agent -s)"           # start the agent
ssh-add ~/.ssh/id_ed25519        # cache the decrypted key so you type the
                                 # passphrase once per session
```

`ed25519` keys are short, fast, and secure; the passphrase encrypts the private
key at rest, and `ssh-agent` holds the decrypted key in memory so you aren't
re-prompted.

### 2. Edit `.ssh/config`.

```
Host vm
    User username_goes_here
    HostName ip_goes_here
    IdentityFile ~/.ssh/id_ed25519
    LocalForward 9999 localhost:8888
```

Now `ssh vm` uses all of these automatically, and `LocalForward` tunnels local
port 9999 to the VM's 8888 (used in exercise 4).

### 3. Use `ssh-copy-id vm` to copy your key to the server.

```bash
ssh-copy-id vm
```

Appends your public key to the VM's `~/.ssh/authorized_keys`, enabling
passwordless (key-based) login.

### 4. Start a webserver on the VM by executing `python -m http.server 8888`. Access the VM webserver from your local machine at `http://localhost:9999`.

On the VM: `python -m http.server 8888`. Locally, because of the `LocalForward`
from exercise 2, open `http://localhost:9999` — traffic is forwarded over the
encrypted SSH connection to the VM's port 8888. (Equivalent one-off command:
`ssh -L 9999:localhost:8888 vm`.)

### 5. Edit your SSH server config (`sudo vim /etc/ssh/sshd_config`) and disable password authentication ... Disable root login ... restart with `sudo service sshd restart`.

```
PasswordAuthentication no
PermitRootLogin no
```

```bash
sudo service sshd restart   # or: sudo systemctl restart ssh
```

Do this **only after** confirming key-based login works, or you can lock
yourself out. Key-only auth defeats password brute-forcing.

### 6. (Challenge) Install `mosh` on the VM and establish a connection. Then disconnect the network adapter... does mosh recover?

```bash
sudo apt install mosh    # on the VM
mosh vm                  # from local
```

Mosh keeps the session alive across IP changes and disconnects because it uses
UDP + a state-synchronisation protocol (SSP) rather than a fixed TCP
connection. Suspending/resuming the network adapter: the session freezes then
resumes right where it was — `ssh` would have dropped.

### 7. (Challenge) Look into what the `-N` and `-f` flags do in `ssh` and figure out a command to set up port forwarding in the background.

- `-N` : do not execute a remote command (just set up forwarding).
- `-f` : go to the background after authentication.

```bash
ssh -N -f -L 9999:localhost:8888 vm
```

Sets up the tunnel and detaches, leaving it running in the background with no
remote shell.
