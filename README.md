# Dotfiles

This repository contains a standalone [Home Manager](https://github.com/nix-community/home-manager) configuration for an `x86_64-linux` workstation.

The flake follows Nixpkgs unstable and Home Manager master. `flake.lock` pins exact revisions so an activation remains reproducible until the inputs are deliberately updated.

## What Home Manager manages

- Linux command-line development tools for Rust, Go, Node.js, Python, Nix, Bazel, and OpenTofu
- Fish and Bash, Starship, fzf, direnv, zoxide, bat, and eza
- Git and GnuPG, including commit signing and GPG-backed SSH agent support
- Neovim, tmux, Alacritty, and the Inconsolata Nerd Font
- Weekly Nix garbage collection for objects older than 30 days

This is intentionally a user-level Home Manager configuration. It does not manage the Linux kernel, bootloader, disks, desktop environment, or other machine-wide NixOS settings.

## Bootstrap

Install Nix using the [official Nix installation instructions](https://nixos.org/download/), clone this repository, and run:

```console
./install.sh
```

The initial activation uses a `home-manager-backup` extension for files that would otherwise conflict. Inspect any resulting backup files before removing them.

Home Manager installs Fish but cannot make it the login shell on a non-NixOS system. After the first successful activation, add the managed Fish executable to `/etc/shells` and use `chsh` if Fish should be the login shell.

## Everyday commands

The repository includes a `justfile`, but every operation can also be run directly:

```console
just build   # Build the activation package without activating it
just check   # Evaluate every flake output for every supported system
just switch  # Build and activate bcmyers@linux
just update  # Refresh flake.lock to the latest upstream revisions
just format  # Format Nix files
just gc      # Delete old Home Manager generations and collect unused store paths
```

The active configuration name is `bcmyers@linux` and its home directory is `/home/bcmyers`.

## State version

`home.stateVersion` is set to `26.05`. This is a compatibility contract, not a package pin. Packages still come from the revisions in `flake.lock`; only change the state version after reading the intervening Home Manager release notes.
