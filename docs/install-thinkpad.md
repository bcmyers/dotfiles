# Install NixOS on the ThinkPad

This runbook replaces Pop!_OS and every partition on the ThinkPad's only internal drive. Nothing on the existing installation is retained.

## Expected machine

- Lenovo ThinkPad X1 Extreme, model `20MF000CUS`
- Internal drive: `/dev/nvme0n1`
- Expected size: approximately `476.9G`
- Expected model: `WDC PC SN720 SDAQNTW-512G-1001`
- UEFI boot with Secure Boot disabled

Stop if any of those facts differ. Never infer the target disk from device ordering alone when another internal disk is present.

## 1. Prepare while Pop!_OS still boots

1. Connect AC power.
2. Apply the available Lenovo system and Intel Management Engine firmware updates with the Pop!_OS firmware updater.
3. Reboot Pop!_OS and confirm the firmware update completed successfully.
4. From an x86_64 Linux machine with KVM, build and review the flake and both VM tests:

   ```console
   ./nix-flake.sh flake check --all-systems --no-build --print-build-logs
   just build
   just build-vm
   just test-disko
   ```

   `just test-disko` formats only a disposable virtual disk. It installs and boots the encrypted layout with a VM-only dummy key.
5. Download the official NixOS 26.05 x86_64 graphical ISO, verify its published SHA-256 checksum, and write it to a USB drive.

## 2. Boot and inspect the installer

Boot the USB explicitly in UEFI mode. Connect Ethernet when practical, open a terminal, and confirm the live environment sees the expected machine:

```console
cat /sys/class/dmi/id/product_name
cat /sys/class/dmi/id/product_version
lsblk -d -o NAME,PATH,SIZE,MODEL,SERIAL
test -d /sys/firmware/efi && echo UEFI || echo BIOS
```

The product name must be `20MF000CUS`, the product version must be `ThinkPad X1 Extreme`, and `/dev/nvme0n1` must be the approximately 477 GiB Western Digital internal drive.

Test Wi-Fi or Ethernet, keyboard, TrackPoint, touchpad, audio, brightness, and suspend before erasing the disk.

## 3. Get the configuration

Connect to the network and clone the reviewed revision:

```console
mkdir -p ~/lib
git clone https://github.com/bcmyers/dotfiles.git ~/lib/dotfiles
cd ~/lib/dotfiles
git switch master
./nix-flake.sh flake check --all-systems --no-build --print-build-logs
```

If the NixOS work is still in a pull request, fetch and switch to its exact reviewed commit instead of `master`.

## 4. Create the temporary LUKS password file

Disko reads the initial passphrase from a root-only file in the live environment's temporary filesystem:

```console
sudo install -m 600 /dev/null /tmp/secret.key
read -r -s -p 'New LUKS passphrase: ' LUKS_PASSWORD
printf '\n'
printf '%s' "$LUKS_PASSWORD" | sudo tee /tmp/secret.key >/dev/null
unset LUKS_PASSWORD
```

This file exists only in live memory and is removed before reboot.

## 5. Final destructive gate

Run the inspection again immediately before Disko:

```console
lsblk -d -o NAME,PATH,SIZE,MODEL,SERIAL
lsblk -o NAME,PATH,TYPE,SIZE,FSTYPE,MOUNTPOINTS /dev/nvme0n1
```

The next command irreversibly destroys the partition table, Pop!_OS recovery environment, current LUKS container, and all files on `/dev/nvme0n1`:

```console
sudo nix --extra-experimental-features "nix-command flakes" run .#disko -- \
  --mode destroy,format,mount \
  --flake '.#thinkpad'
```

Confirm the new filesystems are mounted beneath `/mnt`:

```console
findmnt --real --output TARGET,SOURCE,FSTYPE,OPTIONS | grep '^/mnt'
lsblk -o NAME,PATH,TYPE,SIZE,FSTYPE,MOUNTPOINTS /dev/nvme0n1
```

## 6. Install and set the local password

```console
sudo nix --extra-experimental-features "nix-command flakes" run .#nixos-install -- \
  --flake '.#thinkpad' \
  --no-root-passwd
sudo nixos-enter --root /mnt -c 'passwd bcmyers'
sudo rm -f /tmp/secret.key
```

Remove the USB and reboot. Enter the new LUKS passphrase at the boot prompt and log in locally as `bcmyers`.

## 7. Restore remote access

Bring Tailscale online from the local console:

```console
sudo tailscale up
tailscale status
sudo systemctl status sshd --no-pager
```

The new installation has new SSH host keys and a new Tailscale identity. On the Mac, verify the new ED25519 host-key fingerprint against this local command:

```console
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Only after matching the fingerprint should the obsolete `known_hosts` entry be removed and the new one accepted.

The first Home Manager activation may be unable to decrypt the shared Fish
credentials until the dedicated ThinkPad age identity is installed. After
accepting the verified SSH host key, run these commands on the Mac:

```console
ssh thinkpad 'install -d -m 700 ~/.config/sops/age'
scp "$HOME/Library/Application Support/sops/age/thinkpad-keys.txt" \
  thinkpad:.config/sops/age/keys.txt
ssh thinkpad 'chmod 600 ~/.config/sops/age/keys.txt'
```

Then restart and verify the declarative Home Manager activation on the
ThinkPad:

```console
sudo systemctl restart home-manager-bcmyers.service
systemctl status home-manager-bcmyers.service --no-pager
fish -lc 'set -q ANTHROPIC_API_KEY; and set -q TWILIO_SID; and set -q TWILIO_CLIENT_SECRET'
```

The final command checks only that all three variables exist; it does not print
their values. Never copy either age identity into the repository.

Clone the reviewed configuration into the newly installed user's home directory:

```console
mkdir -p ~/lib
git clone https://github.com/bcmyers/dotfiles.git ~/lib/dotfiles
cd ~/lib/dotfiles
```

Install the current stable Rust toolchain through the Nix-managed Rustup client:

```console
cd ~/lib/dotfiles
just rust-update
```

Rustup owns Rust itself so the compiler can move to a new stable release without waiting for either NixOS stable or nixpkgs-unstable. The Rustup client and the rest of the selected development tools remain pinned by this flake.

## 8. Validate the installation

Before relying on the machine, test:

- COSMIC login and logout
- NVIDIA driver loading with `nvidia-smi`
- Wi-Fi, Ethernet, Tailscale, and SSH from the Mac
- Audio, Bluetooth, printing, keyboard, TrackPoint, touchpad, and brightness
- Suspend and resume several times
- Fish, Git/GPG signing, Neovim, tmux, Alacritty, and direnv
- SOPS-provided Fish variables exist without printing their values
- `just check`, `just build`, and `just switch`
- A previous NixOS generation from the systemd-boot menu

Hibernation is intentionally not configured. The 8 GiB swapfile is for memory pressure and can be resized declaratively later.

## 9. Routine updates

From the repository on the installed ThinkPad:

```console
git pull --ff-only
./nix-flake.sh flake update
just check
just build
just switch
```

Review and commit `flake.lock` updates from a branch rather than updating the running machine from an uncommitted lock file.
