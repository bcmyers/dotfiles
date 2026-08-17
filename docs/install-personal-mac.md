# Install the personal macOS configuration

This runbook covers the first nix-darwin and Home Manager activation on Brian's
personal Apple Silicon Mac. Routine updates require only `git pull --ff-only`, `just
check`, `just build-personal-mac`, and `just switch-personal-mac`.

## 1. Build before activating

From the repository:

```console
just check
just build-personal-mac
```

Then activate nix-darwin and Home Manager:

```console
just switch-personal-mac
```

The first activation uses the `home-manager-backup` extension for files that
would otherwise conflict. Inspect any resulting backup files before removing
them.

## 2. Resolve first-activation `/etc` conflicts

The official Nix installer may have added its initialization block to
`/etc/bashrc`. If nix-darwin refuses to replace that unmanaged file, inspect it
and preserve it before retrying:

```console
diff -u /etc/bashrc.backup-before-nix /etc/bashrc
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
just switch-personal-mac
```

nix-darwin then owns `/etc/bashrc`; the renamed file remains as the
pre-activation backup.

A Homebrew Fish installation may also have added `/opt/homebrew/bin/fish` to
`/etc/shells`. Preserve the old file before letting nix-darwin take ownership:

```console
sudo mv /etc/shells /etc/shells.before-nix-darwin
just switch-personal-mac
```

The declarative version preserves the standard macOS shells and adds the
Nix-managed Fish path.

## 3. Change the existing account's login shell

nix-darwin permits the Nix Fish executable as a login shell but does not change
the shell of an existing macOS account. After activation, run the one-time
account change and open a new terminal:

```console
sudo chsh -s /run/current-system/sw/bin/fish bcmyers
dscacheutil -q user -a name bcmyers
```

Only after the account record reports `/run/current-system/sw/bin/fish` should
the old Homebrew `fish`, `pass`, and `pass-otp` packages be removed.

If `type -a fish` still shows Homebrew ahead of Nix, inspect legacy universal
path state before changing it:

```console
set --show fish_user_paths
```

Only when every listed entry is an obsolete remnant of the old imperative
configuration, remove it once with `set --erase --universal fish_user_paths`.
The managed Fish startup intentionally does not erase universal or global
paths, because installers and work tooling can legitimately use them.

## 4. Verify the migrated environment

Open a fresh Fish shell and verify:

- `type -a fish fzf pass prompt`
- the `c`, `cc`, and `ls` Fish abbreviations
- Password Store decryption
- a GPG-signed Git commit
- SSH authentication through the GPG agent
- `set -q ANTHROPIC_API_KEY TWILIO_SID TWILIO_CLIENT_SECRET` succeeds without
  printing the values

Remove the obsolete plaintext `~/.config/fish/secret.fish` only after the SOPS
variables work. Rotate the Anthropic and Twilio credentials because that legacy
file was previously readable by other local users.
