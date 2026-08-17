# Install Home Manager on a work devbox

This target manages only root's files and Nix profile under `/root` on an
`x86_64-linux` devbox. The Nix package manager must already work as root. The
target does not install or configure Nix, use NixOS, modify `/etc`, manage
services, or change the login shell.

Start the SSH connection from the Nix-managed Alacritty configuration on a Mac
or the ThinkPad. Alacritty allows OSC 52 clipboard writes but deliberately
blocks remote clipboard reads.

Stop if `id -u` is not `0`, `HOME` is not `/root`, or `uname -m` is not
`x86_64`. A separate flake target is required for ARM Linux devboxes.

## 1. Verify the existing Nix installation

```console
id -u
printf '%s\n' "$HOME"
uname -sm
nix --version
git --version
nix --extra-experimental-features 'nix-command flakes' flake metadata \
  'github:NixOS/nixpkgs/nixpkgs-unstable'
```

The last command is only a capability check. This configuration uses its own
locked inputs and does not change the devbox's registry or daemon settings.

## 2. Check out exactly one reviewed Git revision

Choose the full 40-character commit SHA that was reviewed and approved. Do not
bootstrap root from a branch name: a branch can move between the build and the
activation. Fetch only that commit, detach the checkout at it, and verify that
Git resolved the exact value you supplied:

```console
export DOTFILES_REVISION='<full 40-character reviewed commit SHA>'
test "${#DOTFILES_REVISION}" -eq 40

mkdir -p /root/lib/dotfiles
cd /root/lib/dotfiles
git init
git remote add origin https://github.com/bcmyers/dotfiles.git
git fetch --depth=1 origin "$DOTFILES_REVISION"
git switch --detach FETCH_HEAD
test "$(git rev-parse HEAD)" = "$DOTFILES_REVISION"
```

Stop if the final comparison fails. Keep this checkout detached during the
build and activation so no pull or branch switch can change the source.

## 3. Build and activate that same checkout

Home Manager itself does not need to be installed globally. Build the local
activation package first:

```console
nix --extra-experimental-features 'nix-command flakes' build \
  --no-link \
  '.#homeConfigurations."root@work-devbox".activationPackage'
```

Then run the Home Manager executable and configuration from the same local
flake. Activate without `sudo`—the shell is already root:

```console
nix --extra-experimental-features 'nix-command flakes' run \
  '.#home-manager' -- \
  switch \
  --flake '.#"root@work-devbox"' \
  -b home-manager-backup
```

Conflicting files receive the `.home-manager-backup` suffix; inspect them
before removal.

## 4. Update to another reviewed revision

The first activation supplies Just. To update, fetch another reviewed full SHA,
verify the detached checkout again, and only then build and switch:

```console
cd /root/lib/dotfiles
export DOTFILES_REVISION='<new full 40-character reviewed commit SHA>'
test "${#DOTFILES_REVISION}" -eq 40
git fetch --depth=1 origin "$DOTFILES_REVISION"
git switch --detach FETCH_HEAD
test "$(git rev-parse HEAD)" = "$DOTFILES_REVISION"
just build-work-devbox
just switch-work-devbox
```

The guarded switch script refuses to run unless the host is Linux and the
effective user and home directory are `root` and `/root`.

## 5. Shell behavior

Home Manager installs and configures Fish but deliberately leaves root's login
shell under devbox management. Start it explicitly with `fish`. If the devbox
platform has an approved startup hook, that hook may launch Fish separately;
do not change `/etc/passwd` merely to activate this profile.

The managed Fish startup never deletes universal or global `fish_user_paths`.
That preserves paths installed by the devbox platform and work tooling.

## 6. Verify the boundary

Start or attach to tmux with `tmux new -As main`, then run these checks inside
that session:

```console
type -a fish fzf pass prompt nvim tmux aws
git config --global user.email
git config --global commit.gpgsign
printf '%s\n' "${SSH_AUTH_SOCK-}"
tmux show -s set-clipboard
tmux info | grep 'Ms:'
```

The Git email should be `brianmyers@openai.com`; commit signing should be
unset. Home Manager does not start a GPG SSH agent or replace `SSH_AUTH_SOCK`,
and it does not manage `~/.aws/config`. It installs the GPG, Password Store,
and AWS command-line tools without copying personal keys, password entries, or
account credentials.

Alacritty, desktop fonts, Wayland clipboard utilities, Caffeine, and Thaw are
intentionally absent. Run Neovim inside tmux on a devbox. Tmux uses its native
OSC 52 support to send copied text through SSH to the attached terminal; it
does not use a platform-specific clipboard helper or read `SSH_TTY` directly.
`set-clipboard` should report `external`, and `Ms` must not report `[missing]`.
Use Command-V on macOS or Control-Shift-V on Linux to paste local clipboard
contents into a remote terminal instead of allowing remote clipboard reads.

Never copy the personal age identity, GPG private keys, Password Store data,
or `secrets/personal.yaml` access to a work devbox.
