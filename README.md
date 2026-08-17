# ThinkPad NixOS configuration

This repository declaratively manages Brian's complete Lenovo ThinkPad X1 Extreme installation with NixOS and Home Manager.

## Machine

- Host: `thinkpad`
- Platform: `x86_64-linux`
- User: `bcmyers` at `/home/bcmyers`
- NixOS and Home Manager: release 26.05
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
- Weekly Nix garbage collection for objects older than 30 days

## Commands

```console
just check       # Evaluate all flake outputs
just build       # Build the complete NixOS system
just build-home  # Build standalone Home Manager
just build-vm    # Build the safe headless VM variant
just test-disko  # Install and boot the encrypted layout in an isolated VM
just vm          # Build and run the VM
just switch      # Build and activate NixOS on the installed ThinkPad
just update      # Update all locked inputs
just format      # Format Nix files
```

The regular VM variant disables Disko and NVIDIA, uses a disposable QEMU disk, exposes guest SSH on host port `2222`, and automatically logs in as `bcmyers` on its serial console. Its temporary password is `nixos-vm`; that password is not present in the production configuration. The separate Disko test formats a disposable virtual disk, installs and boots NixOS from its encrypted root, and verifies LUKS, ext4, and the swapfile with a VM-only dummy key.

## State versions

Both `system.stateVersion` and `home.stateVersion` are `26.05`. These values control compatibility defaults and should not be changed merely when inputs are updated.
