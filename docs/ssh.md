# SSH, GPG, and GitHub credentials

Home Manager owns the personal SSH client configuration in
`users/bcmyers/ssh.nix`, including Tailscale aliases, login names, identity
selection, and disabled agent forwarding. NixOS owns the ThinkPad's inbound
authorized public keys. Private keys, passphrases, known-host history, GitHub
tokens, and Codex login state remain local. Never put them in Nix expressions
or copy them into the repository.

## One SSH key per personal device

| Device | Private key path | SSH agent |
| --- | --- | --- |
| ThinkPad | `~/.ssh/id_ed25519_thinkpad` | Home Manager OpenSSH agent, two-hour cache |
| MacBook | `~/.ssh/id_ed25519` | Existing GPG agent retained during migration |

The ThinkPad's desktop GCR agent is disabled so there is one SSH agent.
OpenSSH's `IdentityAgent` explicitly selects it for GUI applications as well
as shells. GPG remains available for Password Store and Git signing.

The Mac's Ed25519 key was independently tested against GitHub with its agent
disabled on 2026-09-05. GitHub therefore selects that key exclusively. Other
Mac destinations still permit the existing GPG-agent identities until their
device-key access is tested. Do not remove working authorizations prematurely.

The existing Mac key is also the public key in `files/ssh/macbook.pub` that
NixOS authorizes for inbound ThinkPad SSH. Its verified fingerprint is:

```text
SHA256:ZFZ11pal8yzJMGLD4QLqLeTFaBixoGo+pLpBsyu2HAY
```

## Provision the ThinkPad key

The key created on Pop!_OS was a temporary bootstrap key without a passphrase.
The fresh NixOS installation should get its own permanent, passphrase-protected
key. First check whether the configured file already exists; do not overwrite
an existing identity.

```console
ls -l ~/.ssh/id_ed25519_thinkpad*
install -d -m 700 ~/.ssh
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519_thinkpad -C bcmyers@thinkpad
ssh-add ~/.ssh/id_ed25519_thinkpad
ssh-keygen -lf ~/.ssh/id_ed25519_thinkpad.pub
```

Enter the passphrase interactively. Using the already working Mac-to-ThinkPad
connection, retrieve only the new `.pub` file and authorize it on the Mac.
Add that public key to the personal GitHub account with a device-specific
label, and to other servers where ThinkPad access is needed. Test each
destination before retiring its temporary or historical key.

```console
ssh macbook true
ssh -T git@github.com
```

GitHub's successful authentication message is accompanied by exit status 1
because GitHub does not provide a shell. Check the message, not just the code.
`IdentitiesOnly yes` on the ThinkPad prevents fallback to unrelated keys.

The old Pop!_OS bootstrap key fingerprint is
`SHA256:8vrdYfLTSqvY3oiD2wSvIY+ZA8TRuE0GcDK4Jzyk+/E`; remove that
authorization only after the replacement is tested. Unknown historical
GitHub keys still need their owning devices identified before revocation.

## Host verification and Home Manager migration

Tailnet aliases and full names share a canonical fully qualified
`HostKeyAlias`. Older manually written configurations used short aliases,
including an ambiguous alias on the Mac. Verify host fingerprints locally on
the destination when migrating trust entries; do not disable verification to
silence a mismatch. Reinstalling NixOS also creates new SSH host keys.

GitHub's published Ed25519 host key is committed in
`files/ssh/github-known-hosts`. GitHub connections use strict checking and
consult both this file and the normal writable `~/.ssh/known_hosts`. If GitHub
rotates its key, verify the new published fingerprint and update the file.

Review any existing `~/.ssh/config` before the first activation. Home Manager
backs it up with the configured `home-manager-backup` extension; merge any
additional required hosts into the Nix module. Private key files and the
ordinary `known_hosts` file are not managed or deleted by this module.

## GitHub account and API access

Use the device SSH key for ordinary personal Git operations. Home Manager sets
`gh`'s preferred Git protocol to SSH; GitHub CLI API authentication is a
separate local login. In the desktop session:

```console
gh auth login --hostname github.com --git-protocol ssh --web --skip-ssh-key
gh auth status
```

The preferred protocol does not rewrite existing clone URLs. After the device
key authenticates successfully, switch the bootstrap dotfiles clone to SSH if
you will push changes from it:

```console
git -C ~/lib/dotfiles remote set-url origin git@github.com:bcmyers/dotfiles.git
```

Use the OS credential store when available and check for any plaintext-storage
warning from `gh`. Keep the account protected with a passkey or two-factor
authentication and keep recovery codes in the password manager with a recovery
copy. Public SSH keys are safe to commit; credentials are not.

An account SSH key can access the repositories allowed to that account. Codex
runs as `bcmyers`, so a differently named token or key does not isolate it from
other credentials readable by that user. Do not treat this setup as a separate
automation security boundary.

For future unattended automation, prefer an expiring fine-grained token limited
to the selected repositories and required permissions, or a GitHub App for
short-lived installation tokens. Enforce important branch protections on
GitHub and review changes before merging. Changing Git author information or
signing a commit does not establish that a human reviewed it.

## GPG and Password Store

Keep the primary GPG secret key on the Mac. Restore personal secret subkeys on
the ThinkPad for decryption and signing as described in the installation
runbook. Do not migrate the Mac's GPG SSH inventory onto the ThinkPad.
Password Store entries remain encrypted and need their own tested restore
source; installing `pass` does not restore passwords.

## References

- [GitHub SSH host fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
- [GitHub CLI authentication](https://cli.github.com/manual/gh_auth_login)
- [GitHub access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- [GitHub App installation authentication](https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/authenticating-as-a-github-app-installation)
