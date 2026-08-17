# NixOS and macOS dotfiles

This repository declaratively manages Brian's complete Lenovo ThinkPad X1 Extreme installation with NixOS and Home Manager, plus his Apple Silicon Mac with nix-darwin and Home Manager.

## Repository layout

- `hosts/` contains machine-specific system configuration. The ThinkPad is
  split by boot, hardware, networking, storage, desktop, users, and VM test
  concerns; the smaller Mac configuration remains a single module.
- `modules/common/` contains system-level wiring shared by NixOS and
  nix-darwin.
- `modules/home/` is the shared Home Manager profile. Platform-specific
  differences are isolated under `platform/`, and program configuration is
  grouped by concern under `programs/`.
- `files/` contains raw files installed by Home Manager, currently Neovim
  configuration and the tmux clipboard helper.
- `pkgs/` contains locally defined Nix packages.
- `scripts/` contains flake and activation helpers; `justfile` is the
  normal command interface.
- `docs/` and `secrets/` contain machine runbooks and SOPS material.
- `archive/web-server/` preserves an old, non-deployed nginx/Certbot
  configuration as explicit migration input rather than mixing it with the
  workstation modules.

The standalone Home Manager outputs remain available as migration and
evaluation targets, but the deployed machines use the complete NixOS and
nix-darwin configurations.

## Machine

- Host: `thinkpad`
- Platform: `x86_64-linux`
- User: `bcmyers` at `/home/bcmyers`
- NixOS and system packages: release 26.05
- Selected user tools: nixpkgs-unstable
- Desktop: COSMIC
- Graphics: NVIDIA GTX 1050 Ti using the legacy 580 driver
- Remote access: Tailscale and key-only OpenSSH, with only SSH admitted on the
  Tailnet interface

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

This passphrase-based layout does **not** boot unattended. Firmware can power
the laptop back on after an outage, but NixOS stops at the LUKS prompt until
someone enters the passphrase. Before installation, explicitly choose either
manual unlock, a separately designed and tested unattended unlock mechanism,
or an unencrypted root. The current configuration implements manual unlock.

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

The repository does not depend on Nix channels or an ambient `<nixpkgs>`. Every Nix input, package, rebuild tool, and formatter is resolved through `flake.nix` and `flake.lock`. `scripts/nix-flake.sh` explicitly enables `nix-command` and `flakes`, which also makes the bootstrap commands work before Home Manager, NixOS, or nix-darwin has written the permanent Nix settings.

Useful flake entry points include:

```console
./scripts/nix-flake.sh flake show --all-systems
./scripts/nix-flake.sh flake check --all-systems --no-build
./scripts/nix-flake.sh build .#prompt
./scripts/nix-flake.sh run .#age-keygen -- --help
./scripts/nix-flake.sh run .#sops -- --version
./scripts/nix-flake.sh run .#nixos-install -- --help  # x86_64 Linux
./scripts/nix-flake.sh run .#nixos-rebuild -- --help  # x86_64 Linux
./scripts/nix-flake.sh run .#darwin-rebuild -- --help # Apple Silicon macOS
```

The non-flake `prompt-src` input is intentional: it imports the source archive of the separate prompt repository into this flake, and its exact revision and content hash are still locked.

## Mac nix-darwin

The `mac` nix-darwin target shares command-line tools, Fish configuration and abbreviations, the custom `prompt` executable, Git/GPG configuration, Neovim, tmux, Alacritty, and other user preferences with the ThinkPad. It targets `aarch64-darwin` and `/Users/bcmyers`.

nix-darwin owns the system Nix settings and the list of permitted login shells;
Home Manager owns the user profile, Password Store, GPG/SSH agent, Fish, and
dotfiles. Changing an existing macOS account to use Nix-managed Fish remains a
one-time account operation. SOPS decrypts the Fish API credentials at
activation time using the age key at
`~/Library/Application Support/sops/age/keys.txt`. The private key is never
committed.

The Mac and ThinkPad consume the same encrypted `secrets/shared.yaml` document,
but each machine has its own private age identity. Linux reads
`~/.config/sops/age/keys.txt`. See [the secrets guide](secrets/README.md) and
[ThinkPad installation runbook](docs/install-thinkpad.md) for provisioning.

Build and activate it with:

```console
just build-mac
just switch-mac
```

See [the Mac installation and migration runbook](docs/install-mac.md) for the
first activation, `/etc` ownership conflicts, the one-time login-shell change,
and post-migration verification.

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
