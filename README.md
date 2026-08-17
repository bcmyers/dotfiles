# NixOS and macOS dotfiles

This repository declaratively manages Brian's complete Lenovo ThinkPad X1 Extreme installation with NixOS and Home Manager, plus his Apple Silicon Mac with nix-darwin and Home Manager.

## Machine

- Host: `thinkpad`
- Platform: `x86_64-linux`
- User: `bcmyers` at `/home/bcmyers`
- NixOS and system packages: release 26.05
- Selected user tools: nixpkgs-unstable
- Desktop: COSMIC
- Graphics: NVIDIA GTX 1050 Ti using the legacy 580 driver
- Remote access: Tailscale and key-only OpenSSH

## Disk layout

The installation intentionally erases `/dev/nvme0n1` and creates:

```text
GPT
├── 1 GiB FAT32 EFI System Partition mounted at /boot
└── remaining space as LUKS2 cryptroot
    └── one ext4 root filesystem
        └── an 8 GiB encrypted swapfile at /var/lib/swapfile
```

There is no LVM or separate `/home` partition. See [the installation runbook](docs/install-thinkpad.md) before running Disko.

## What NixOS manages

- UEFI boot with systemd-boot and eight retained boot generations
- LUKS2 encrypted root, ext4, swapfile, and weekly SSD trimming
- COSMIC, audio, Bluetooth, printing, power management, firmware updates, and virtualization
- NetworkManager, Tailscale, firewall policy, and OpenSSH
- Fish, Git/GPG, Neovim, tmux, Alacritty, and development toolchains through Home Manager
- Shared Fish API credentials decrypted by SOPS with a dedicated ThinkPad age identity
- Weekly Nix garbage collection for objects older than 30 days

## Package channels

The ThinkPad deliberately keeps its operating system on the stable NixOS 26.05 branch. Home Manager receives a second, pinned `nixpkgs-unstable` package set for tools where current releases matter: Fish, Neovim, GnuPG, Go, Node.js, Python, Rustup, Nix language tooling, OpenTofu, Pulumi, `uv`, and related development tools. Core system services, the kernel, NVIDIA driver, boot stack, and disk configuration remain stable.

The Mac uses nixpkgs-unstable throughout because it is a workstation user environment rather than the recovery-sensitive laptop operating system. Both channels are locked in `flake.lock`, so "unstable" means deliberately updated, reviewed revisions rather than an unrepeatable moving target.

Rust itself is managed by Rustup rather than Nix so that stable Rust can be updated immediately without waiting for Nixpkgs. After the first activation on a new machine, run `just rust-update`.

## Flake workflow

The repository does not depend on Nix channels or an ambient `<nixpkgs>`. Every Nix input, package, rebuild tool, and formatter is resolved through `flake.nix` and `flake.lock`. `nix-flake.sh` explicitly enables `nix-command` and `flakes`, which also makes the bootstrap commands work before Home Manager, NixOS, or nix-darwin has written the permanent Nix settings.

Useful flake entry points include:

```console
./nix-flake.sh flake show --all-systems
./nix-flake.sh flake check --all-systems --no-build
./nix-flake.sh build .#prompt
./nix-flake.sh run .#age-keygen -- --help
./nix-flake.sh run .#sops -- --version
./nix-flake.sh run .#nixos-install -- --help  # x86_64 Linux
./nix-flake.sh run .#nixos-rebuild -- --help  # x86_64 Linux
./nix-flake.sh run .#darwin-rebuild -- --help # Apple Silicon macOS
```

The non-flake `prompt-src` input is intentional: it imports the source archive of the separate prompt repository into this flake, and its exact revision and content hash are still locked.

## Mac nix-darwin

The `mac` nix-darwin target shares command-line tools, Fish configuration and abbreviations, the custom `prompt` executable, Git/GPG configuration, Neovim, tmux, Alacritty, and other user preferences with the ThinkPad. It targets `aarch64-darwin` and `/Users/bcmyers`.

nix-darwin owns the system Nix settings and login shell; Home Manager owns the user profile, Password Store, GPG/SSH agent, Fish, and dotfiles. SOPS decrypts the Fish API credentials at activation time using the age key at `~/Library/Application Support/sops/age/keys.txt`. The private key is never committed.

The Mac and ThinkPad consume the same encrypted `secrets/shared.yaml` document,
but each machine has its own private age identity. Linux reads
`~/.config/sops/age/keys.txt`. See [the secrets guide](secrets/README.md) and
[ThinkPad installation runbook](docs/install-thinkpad.md) for provisioning.

Build and activate it with:

```console
just build-mac
just switch-mac
```

`just switch-mac` activates nix-darwin and Home Manager. The first activation uses the `home-manager-backup` extension for files that would otherwise conflict. Inspect any resulting backup files before removing them.

The official Nix installer may have added its initialization block to
`/etc/bashrc`. If the first activation refuses to replace that unmanaged file,
inspect it and preserve it before retrying:

```console
diff -u /etc/bashrc.backup-before-nix /etc/bashrc
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
just switch-mac
```

nix-darwin then owns `/etc/bashrc`; the renamed file remains available as the
pre-activation backup.

A Homebrew Fish installation may also have added `/opt/homebrew/bin/fish` to
`/etc/shells`. The nix-darwin version preserves every standard macOS shell and
replaces the Homebrew entry with the Nix-managed Fish path. Preserve the old
file before the first activation takes ownership:

```console
sudo mv /etc/shells /etc/shells.before-nix-darwin
just switch-mac
```

nix-darwin does not change the login shell of an existing macOS account. After
the first activation has added Nix Fish to `/etc/shells`, make the one-time
macOS account change and open a new terminal:

```console
sudo chsh -s /run/current-system/sw/bin/fish bcmyers
```

Only after `dscacheutil -q user -a name bcmyers` reports the Nix Fish path
should the old Homebrew packages be removed with `brew uninstall fish pass`.

After the first successful activation, open a fresh Fish shell and verify that `prompt`, the Fish abbreviations, Password Store, GPG signing, and SSH through the GPG agent all work. Confirm the three SOPS-provided environment variables are set without printing their values, then remove the obsolete plaintext `~/.config/fish/secret.fish`. Rotate the Anthropic and Twilio credentials because that legacy file was previously readable by other local users.

## Commands

```console
just check       # Evaluate all flake outputs
just show        # Display every flake output for both systems
just build       # Build the complete NixOS system
just build-home-linux # Build standalone Linux Home Manager
just build-home-mac   # Build standalone Mac Home Manager
just build-mac        # Build the complete nix-darwin system
just build-vm    # Build the safe headless VM variant
just test-disko  # Install and boot the encrypted layout in an isolated VM
just vm          # Build and run the VM
just switch      # Build and activate NixOS on the installed ThinkPad
just switch-mac  # Build and activate nix-darwin and Home Manager on this Mac
just edit-secrets # Edit the shared encrypted SOPS document
just rust-update # Update stable Rust and standard developer components
just update      # Update all locked inputs
just format      # Format Nix files
```

The regular VM variant disables Disko and NVIDIA, uses a disposable QEMU disk, exposes guest SSH on host port `2222`, and automatically logs in as `bcmyers` on its serial console. Its temporary password is `nixos-vm`; that password is not present in the production configuration. The separate Disko test formats a disposable virtual disk, installs and boots NixOS from its encrypted root, and verifies LUKS, ext4, and the swapfile with a VM-only dummy key.

## State versions

The ThinkPad's `system.stateVersion` and both Home Manager targets' `home.stateVersion` are `26.05`. These values control compatibility defaults and should not be changed merely when inputs are updated.
