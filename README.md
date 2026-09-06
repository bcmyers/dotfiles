# NixOS and macOS dotfiles

This repository declaratively manages Brian's Lenovo ThinkPad with NixOS and
Home Manager, his personal Apple Silicon Mac with nix-darwin and Home Manager,
his work Apple Silicon Mac with standalone Home Manager, and root shells on
x86_64 and ARM Linux work devboxes with standalone Home Manager.

## Repository layout

- `hosts/` contains machine-specific system configuration. The ThinkPad is
  split by boot, hardware, networking, Disko storage, desktop, users, and
  virtualization concerns. The personal Mac owns its nix-darwin integration;
  the work Mac and work devbox own standalone Home Manager entry points.
- `modules/system/` contains system-level wiring shared by NixOS and
  nix-darwin.
- `modules/home/` contains reusable Home Manager modules. Platform-specific
  differences are isolated under `platform/`, and program configuration is
  grouped by concern under `programs/`. Host-selected GUI applications are
  under `apps/`, so headless hosts do not inherit them.
- `profiles/home/` composes those modules into a full workstation or a narrow
  work-devbox capability set. Account-independent identity policy lives under
  `profiles/home/identities/`.
- `users/` supplies account identity and policy around the shared profile.
  Git signing, GPG-agent SSH keys, AWS defaults, hosted editor integrations,
  and personal SOPS secrets belong only to `bcmyers`; `brian.myers` is the
  secret-free work profile.
- `files/` contains the Neovim configuration and public SSH trust material.
- `pkgs/` contains locally defined Nix packages.
- `scripts/` contains flake and activation helpers; `justfile` is the
  normal command interface.
- `docs/` and `secrets/` contain machine runbooks and SOPS material.
- `archive/web-server/` preserves an old, non-deployed nginx/Certbot
  configuration as explicit migration input rather than mixing it with the
  workstation modules.

The ThinkPad and personal Mac integrate Home Manager with their system
configurations. The work Mac and work devboxes intentionally use only
standalone Home Manager, leaving their operating systems and corporate system
management untouched.

## ThinkPad

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

The disk keeps a recovery passphrase and supports TPM automatic unlocking.
Initial boots need the passphrase until Secure Boot and the TPM are enrolled
on the installed ThinkPad. Follow [the availability and recovery guide](docs/thinkpad-availability.md)
before relying on unattended restarts. Routine OS updates retain the signing
authority; firmware or Secure Boot policy changes may require recovery.

## What NixOS manages

- Signed UEFI boot with Lanzaboote 1.1.0 and eight retained boot generations
- LUKS2 encrypted root, ext4, swapfile, and weekly SSD trimming
- COSMIC, audio, Bluetooth, printing, power management, firmware updates, and virtualization
- NetworkManager, Tailscale, firewall policy, and OpenSSH
- Fish, Git/GPG, Neovim, tmux, Alacritty, and development toolchains through Home Manager
- Codex CLI and its system defaults, with updates pinned by the Nix flake
- Personal API credentials decrypted by SOPS and supplied to explicit commands
- Firefox and Google Chrome, updated with the pinned NixOS packages
- Weekly Nix garbage collection for objects older than 30 days
- Sleep disabled, clean shutdown at 5% battery, and user services started before login

## Package channels

The ThinkPad deliberately keeps its operating system on the stable NixOS 26.05 branch. Home Manager receives a second, pinned `nixpkgs-unstable` package set for tools where current releases matter: Fish, Neovim, GnuPG, Go, Node.js, Python, Rustup, Nix language tooling, OpenTofu, Pulumi, `uv`, and related development tools. Core system services, the kernel, NVIDIA driver, boot stack, and disk configuration remain stable.

The Nix package manager itself uses `nixVersions.latest` from the pinned
unstable input, selecting its latest released version rather than a development
snapshot. This applies to the NixOS and nix-darwin systems.

Both Mac profiles use nixpkgs-unstable throughout because they are workstation
user environments rather than the recovery-sensitive laptop operating system.
Both channels are locked in `flake.lock`, so "unstable" means deliberately
updated, reviewed revisions rather than an unrepeatable moving target.

Rust itself is managed by Rustup rather than Nix so that stable Rust can be updated immediately without waiting for Nixpkgs. After the first activation on a new machine, run `just rust-update`.

See [Codex on the ThinkPad](docs/codex.md) for sign-in, configuration, and updates.

See [SSH and GitHub credentials](docs/ssh.md) for device keys, agent ownership,
and first-login steps. Nix manages configuration and public keys; private
keys and login tokens remain local.

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

## Personal Mac

The `personal-mac` nix-darwin target shares command-line tools, Fish
configuration and abbreviations, the custom `prompt` executable, personal
Git/GPG configuration, Neovim, tmux, Alacritty, and other user preferences
with the ThinkPad. It targets `aarch64-darwin` and `/Users/bcmyers`.

nix-darwin owns the system Nix settings and the list of permitted login shells;
Home Manager owns the user profile, Password Store, GPG/SSH agent, Fish, and
dotfiles. Changing an existing macOS account to use Nix-managed Fish remains a
one-time account operation. SOPS decrypts the personal API credentials at
activation time using the age key at
`~/Library/Application Support/sops/age/keys.txt`. The private key is never
committed.

The personal Mac and ThinkPad consume the same encrypted
`secrets/personal.yaml` document,
but each machine has its own private age identity. Linux reads
`~/.config/sops/age/keys.txt`. See [the secrets guide](secrets/README.md) and
[ThinkPad installation runbook](docs/install-thinkpad.md) for provisioning.

Build and activate it with:

```console
just build-personal-mac
just switch-personal-mac
```

See [the personal Mac installation and migration
runbook](docs/install-personal-mac.md) for the first activation, `/etc`
ownership conflicts, the one-time login-shell change, and post-migration
verification.

## Work Mac

The `brian.myers@work-mac` target applies the shared Apple Silicon Home Manager
profile to `/Users/brian.myers`. It uses the work Git identity
`brianmyers@openai.com` and shares neutral Fish, Git, GPG, Password Store,
Neovim, tmux, Alacritty, development packages, Caffeine, and Thaw tooling with
the personal Mac.

It does not configure nix-darwin, `/etc`, the account's login shell, system
defaults, the Nix installation, or corporate-managed macOS services. It also
does not import `secrets/personal.yaml`, require an age identity, take over
`SSH_AUTH_SOCK`, configure a signing key or AWS profile, or load the personal
Windsurf integration.

Build and activate it without `sudo`:

```console
just build-work-mac
just switch-work-mac
```

See [the work Mac Home Manager runbook](docs/install-work-mac.md) for first-use
conflicts, application permissions, and the Homebrew Fish handoff.

## Work devboxes

The `root@work-devbox-x86_64-linux` and
`root@work-devbox-aarch64-linux` targets manage a headless CLI environment
under `/root`. They assume the Nix package manager is already installed and
use Home Manager only as a Nix-driven user-environment activator. They do not
install or configure Nix, use NixOS, modify `/etc`, manage services, or change
root's login shell.

The targets share the neutral OpenAI Git identity and core development tools
with the work Mac, but use a deliberately smaller capability profile. They
omit Alacritty, fonts, desktop clipboard packages, Caffeine, Thaw, GPG,
Password Store, SOPS, age, AWS and cloud deployment tools, workstation network
administration tools, and Windsurf integration.

They also preserve the platform-provided root Bash startup files. Fish is
managed under `/root/.nix-profile` and launched explicitly rather than
replacing the devbox login shell or Bash initialization.

Build and activate it as root:

```console
just build-work-devbox
just switch-work-devbox
```

See [the work devbox runbook](docs/install-work-devbox.md) for bootstrap and
verification instructions that require only an existing Nix package manager.

## Clipboard behavior

Alacritty permits OSC 52 clipboard writes but not reads. Tmux uses its native
`set-clipboard external` mode, so copy mode sends text to the attached
Alacritty client without an OS-specific helper. Neovim selects `pbcopy` on
macOS, `wl-copy` on the graphical ThinkPad, and `tmux load-buffer -w -` inside
a devbox tmux session. Use the terminal's normal paste shortcut for the reverse
direction instead of allowing a remote process to read the local clipboard.

The supported remote path is Alacritty to SSH to tmux. Run Neovim inside tmux
on work devboxes.

## Commands

```console
just check       # Scan for secrets and evaluate all flake outputs
just check-secrets # Scan Git history and the working tree for secrets
just install-hooks # Enable the tracked staged-secret pre-commit hook
just show        # Display every flake output for all supported systems
just build-thinkpad    # Build the complete NixOS system
just build-personal-mac # Build the complete nix-darwin system
just build-work-mac   # Build standalone work Mac Home Manager
just build-work-devbox # Build standalone root Home Manager for Linux devboxes
just build-vm    # Build the safe headless VM variant
just test-disko  # Install and boot the encrypted layout in an isolated VM
just vm          # Build and run the VM
just switch-thinkpad # Build and activate NixOS on the installed ThinkPad
just switch-personal-mac # Activate nix-darwin and Home Manager on the personal Mac
just switch-work-mac # Activate Home Manager only on the work Mac
just switch-work-devbox # Activate Home Manager only under /root on a work devbox
just edit-secrets # Edit the personal encrypted SOPS document
just rust-update # Update stable Rust and standard developer components
just update      # Update all locked inputs
just format      # Format Nix files
```

`just install-hooks` materializes Gitleaks from the exact nixpkgs-unstable
revision in `flake.lock` without evaluating this repository as a flake. The
hook refreshes the scanner when the locked revision changes, then invokes that
immutable binary directly, so a rejected staged secret
is not first copied into the Nix store as part of the candidate source tree.
The installer does not change Git's filesystem-monitor settings. If a broken
global filesystem monitor prevents the staged scan from reading the index,
disable it only in the affected clone with
`git config --local core.fsmonitor false` after confirming the failure.

The regular VM variant disables Disko and NVIDIA, uses a disposable QEMU disk,
exposes key-only guest SSH at `127.0.0.1:2222`, and automatically logs in as
`bcmyers` on its serial console. Its temporary local-console password is
`nixos-vm`; that password is not accepted over SSH and is not present in the
production configuration. The separate Disko test formats a disposable
virtual disk, installs and boots NixOS from its encrypted root, and verifies
LUKS, ext4, and the swapfile with a VM-only dummy key.

## State versions

The ThinkPad's `system.stateVersion`, the personal Mac's nix-darwin state
version, and all four Home Manager profiles have explicit compatibility state
versions. These values should not be changed merely when inputs are updated.
