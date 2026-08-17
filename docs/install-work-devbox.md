# Install Home Manager on a work devbox

This target manages only root's files and Nix profile under `/root` on an
`x86_64-linux` devbox. The Nix package manager must already work as root. The
target does not install or configure Nix, use NixOS, modify `/etc`, manage
services, or change the login shell.

Stop if `id -u` is not `0`, `HOME` is not `/root`, or `uname -m` is not
`x86_64`. A separate flake target is required for ARM Linux devboxes.

## 1. Verify the existing Nix installation

```console
id -u
printf '%s\n' "$HOME"
uname -sm
nix --version
nix --extra-experimental-features 'nix-command flakes' flake metadata \
  'github:NixOS/nixpkgs/nixpkgs-unstable'
```

The last command is only a capability check. This configuration uses its own
locked inputs and does not change the devbox's registry or daemon settings.

## 2. Bootstrap directly from the reviewed Git revision

Home Manager itself does not need to be installed globally. From the reviewed
branch or commit, first build the activation package:

```console
nix --extra-experimental-features 'nix-command flakes' build \
  --no-link \
  'git+https://github.com/bcmyers/dotfiles.git?ref=refs/heads/codex/linux-home-manager-refresh#homeConfigurations."root@work-devbox".activationPackage'
```

Then activate it without `sudo`—the shell is already root:

```console
nix --extra-experimental-features 'nix-command flakes' run \
  'git+https://github.com/bcmyers/dotfiles.git?ref=refs/heads/codex/linux-home-manager-refresh#home-manager' -- \
  -b home-manager-backup \
  --flake 'git+https://github.com/bcmyers/dotfiles.git?ref=refs/heads/codex/linux-home-manager-refresh#"root@work-devbox"' \
  switch
```

Replace the branch reference with `master` after the pull request is merged,
or use an exact reviewed commit for reproducible provisioning. Conflicting
files receive the `.home-manager-backup` suffix; inspect them before removal.

## 3. Clone for routine updates

The first activation supplies Git and Just. Keep the checkout under `/root/lib`:

```console
mkdir -p /root/lib
git clone https://github.com/bcmyers/dotfiles.git /root/lib/dotfiles
cd /root/lib/dotfiles
git switch codex/linux-home-manager-refresh
just build-work-devbox
just switch-work-devbox
```

The guarded switch script refuses to run unless the host is Linux and the
effective user and home directory are `root` and `/root`.

## 4. Shell behavior

Home Manager installs and configures Fish but deliberately leaves root's login
shell under devbox management. Start it explicitly with `fish`. If the devbox
platform has an approved startup hook, that hook may launch Fish separately;
do not change `/etc/passwd` merely to activate this profile.

The managed Fish startup never deletes universal or global `fish_user_paths`.
That preserves paths installed by the devbox platform and work tooling.

## 5. Verify the boundary

```console
type -a fish fzf pass prompt nvim tmux aws
git config --global user.email
git config --global commit.gpgsign
printf '%s\n' "${SSH_AUTH_SOCK-}"
```

The Git email should be `brianmyers@openai.com`; commit signing should be
unset. Home Manager does not start a GPG SSH agent or replace `SSH_AUTH_SOCK`,
and it does not manage `~/.aws/config`. It installs the GPG, Password Store,
and AWS command-line tools without copying personal keys, password entries, or
account credentials.

Alacritty, desktop fonts, Wayland clipboard utilities, Caffeine, and Thaw are
intentionally absent. Tmux copy mode falls back to OSC 52 so clipboard yanks
can travel through the SSH terminal.

Never copy the personal age identity, GPG private keys, Password Store data,
or `secrets/personal.yaml` access to a work devbox.
