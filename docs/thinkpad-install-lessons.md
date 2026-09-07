# Reusing the ThinkPad installation work

The original installation guide records the reviewed September 5 installation
and its exact system commit. The following lessons and helpers come from the
completed physical installation. For a new installation, first review and
build the branch you intend to install; do not blindly reuse an old commit or
a previous machine's disk identity, TPM token, signing keys, or owner GUID.

## SSH and interactive commands

1. Verify the ThinkPad's SSH host key at its physical console before adding
   trust on the Mac. A timeout is a reachability problem: inspect Tailscale
   status, the admin access rules, the destination address, and the SSH
   service before changing keys or authentication.
2. For initial bootstrap, connect from the Mac to the current ThinkPad IP.
   Mac-to-ThinkPad setup does not need a working reverse SSH connection.
3. Use a terminal allocation (`ssh -t`) for sudo and GPG passphrase prompts.
   Send Bash programs through an explicitly quoted `bash -lc`; the remote
   login shell may be Fish.
4. Once naming is stable, use the verified `thinkpad` SSH alias instead of
   copying a Tailscale IP into each helper. Keep device authorization expiry
   and the tailnet access rules consistent with the intended always-on host.

## GPG restoration

The old pipeline that directly imported secret subkeys over a noninteractive
SSH connection failed with `Inappropriate ioctl for device`. From an
interactive Mac terminal, use the repository helper instead:

```sh
bash scripts/restore-thinkpad-gpg.sh
```

During initial bootstrap, if the hostname is not ready yet:

```sh
THINKPAD_HOST=100.x.y.z bash scripts/restore-thinkpad-gpg.sh
```

Use the actual ThinkPad address in place of the example. The helper retains
strict host-key verification against the verified ThinkPad hostname. It
streams only secret subkeys, stages them in a private directory on the
ThinkPad's runtime tmpfs, imports them with an interactive GPG terminal, and
removes the temporary export. The primary secret key stays on the Mac.

Do not commit private keys, exports, archive passphrases, or login tokens.
GPG ownership trust and Password Store restoration remain explicit checks in
the installation guide.

## Firmware, Secure Boot, and disk unlocking

1. Firmware settings remain physical steps. Set and save the supervisor
   password, enable Power On with AC Attach, and follow the documented
   Setup Mode procedure. A power-on password would prevent unattended boot.
2. Back up and verify the newly generated signing keys on another device
   before enrolling them. Check the archive contains PK, KEK, db signing
   keys, and the owner GUID, rather than merely checking that it decrypts.
3. This ThinkPad initially marked the `KEK` and `db` EFI variables immutable.
   If `sbctl` reports that error, inspect those exact files. Record their
   attributes, temporarily clear only their immutable flags, enroll, and
   restore the original flags even on failure. Preserve `dbx`; do not use a
   broad `chattr` command, delete EFI variables, or force an unsafe enrollment.
4. The TPM enrollment helper checks the actual parent device returned by
   `lsblk`, which can already be an absolute path. The fixed helper avoids
   constructing an invalid `/dev//dev/...` path.
5. Prove the recovery passphrase works before adding TPM unlocking. Keep its
   key slot. Check signed unified boot images, Secure Boot, and measured UKI
   state before enrollment; an unsigned detached kernel alone is expected.
6. Test reboot to the login screen, SSH before local login, lid closure, and
   power recovery separately. These test different parts of unattended use.

## Desktop and application checks

Use [workstation checks](workstation-checks.md) for the installed Caps Lock
mapping, tmux settings, and `just test-nvim`. Browser sign-in alone is not
Codex CLI sign-in: complete `codex login` and verify `codex login status`.

[The COSMIC upgrade helper](cosmic-remote-desktop.md) builds and tests the new
desktop before installing a boot generation. Its VM checks portals and panel
startup; the physical dock, NVIDIA display, and remote mouse/keyboard still
need a real-session test. Avoid resetting an existing COSMIC profile just to
repair one panel or applet.

[ChatGPT's updater](chatgpt-linux.md) keeps the official Linux preview current
without requiring a whole-system rebuild.
