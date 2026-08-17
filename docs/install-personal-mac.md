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

Activation installs missing declared Homebrew casks and uninstalls undeclared
ones with ordinary Homebrew cleanup. It deliberately does not upgrade existing
casks, so an unavailable vendor download cannot block the rest of the system
activation. Most declared GUI apps update themselves; run
`just upgrade-homebrew-casks` when you explicitly want Homebrew to update its
metadata and upgrade the remaining casks. Application support data is
preserved because activation does not use `--zap`. Add a cask to
`hosts/personal-mac/default.nix` before installing it when it should remain on
the machine.

The first activation uses the `home-manager-backup` extension for files that
would otherwise conflict. Inspect any resulting backup files before removing
them.

## 2. Resolve first-activation `/etc` conflicts

The official Nix installer may have added its initialization block to
`/etc/bashrc`. If nix-darwin refuses to replace that unmanaged file, inspect it
and preserve it before retrying:

```console
diff -u /etc/bashrc.backup-before-nix /etc/bashrc
bashrc_backup="/etc/bashrc.before-nix-darwin.$(date +%Y%m%d-%H%M%S)"
test ! -e "$bashrc_backup"
sudo mv /etc/bashrc "$bashrc_backup"
printf 'Preserved the old file at %s\n' "$bashrc_backup"
just switch-personal-mac
```

If the original installer backup does not exist, inspect `/etc/bashrc`
directly instead of skipping review. The timestamped destination is checked
before the move, so retrying this procedure cannot silently overwrite an older
backup. nix-darwin then owns `/etc/bashrc`.

A Homebrew Fish installation may also have added `/opt/homebrew/bin/fish` to
`/etc/shells`. Preserve the old file before letting nix-darwin take ownership:

```console
sed -n '1,240p' /etc/shells
shells_backup="/etc/shells.before-nix-darwin.$(date +%Y%m%d-%H%M%S)"
test ! -e "$shells_backup"
sudo mv /etc/shells "$shells_backup"
printf 'Preserved the old file at %s\n' "$shells_backup"
just switch-personal-mac
```

Review any nonstandard shell entries before the move and add entries that must
survive to the declarative host configuration. The current declarative version
preserves the standard macOS shells and adds the Nix-managed Fish path.

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

A legacy `~/.zprofile` may still run `brew shellenv`. Once nix-darwin supplies
the system PATH, inspect that file and remove or archive the obsolete line. If
the file contains nothing else worth retaining, preserve it under a unique
name instead of letting every zsh login evaluate Fish syntax:

```console
sed -n '1,160p' ~/.zprofile
zprofile_backup="$HOME/.zprofile.before-nix.$(date +%Y%m%d-%H%M%S)"
test ! -e "$zprofile_backup"
mv ~/.zprofile "$zprofile_backup"
```

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
file stored them as persistent plaintext and may still exist in backups.

## 5. Recover or roll back

List the nix-darwin system generations before selecting a rollback:

```console
sudo /run/current-system/sw/bin/darwin-rebuild --list-generations
sudo /run/current-system/sw/bin/darwin-rebuild switch --rollback
```

Open a new terminal after rollback. If the current system path is damaged, use
the corresponding `darwin-rebuild` executable from a retained generation under
`/nix/var/nix/profiles/system-*-link/sw/bin/`. Before switching forward again,
return the repository to a known-good reviewed commit. Individual
`.home-manager-backup` files can restore pre-activation content, but they do not
replace a complete nix-darwin generation rollback.
