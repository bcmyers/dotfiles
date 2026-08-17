# Install NixOS on the ThinkPad

This runbook replaces Pop!_OS and every partition on the ThinkPad's only internal drive. Nothing on the existing installation is retained.

## Expected machine

- Lenovo ThinkPad X1 Extreme, model `20MF000CUS`
- Internal drive: `/dev/nvme0n1`
- Expected size: approximately `476.9G`
- Expected model: `WDC PC SN720 SDAQNTW-512G-1001`
- UEFI boot with Secure Boot disabled

Stop if any of those facts differ. Never infer the target disk from device ordering alone when another internal disk is present.

## Availability decision before installation

The checked-in layout encrypts the complete root filesystem with a manually
entered LUKS passphrase. Lenovo firmware can power the laptop back on after an
outage, but the machine will wait at the unlock prompt and will not return to
Tailscale or SSH by itself.

Do not install this layout while unattended recovery is a requirement. First
choose and test one of these policies:

- keep the current manual unlock and accept that someone must be physically
  present after a full power loss;
- design a separately protected TPM2, FIDO2, or network-bound unlock path with
  a recovery key; or
- remove root encryption after explicitly accepting the data-at-rest risk.

The current configuration and Disko test implement only the first policy.

## 1. Prepare while Pop!_OS still boots

1. Connect AC power.
2. Apply the available Lenovo system and Intel Management Engine firmware updates with the Pop!_OS firmware updater.
3. Reboot Pop!_OS and confirm the firmware update completed successfully.
4. From an x86_64 Linux machine with KVM, build and review the flake and both VM tests:

   ```console
   ./scripts/nix-flake.sh flake check --all-systems --no-build --print-build-logs
   just build-thinkpad
   just build-vm
   just test-disko
   ```

   `just test-disko` formats only a disposable virtual disk. It installs and boots the encrypted layout with a VM-only dummy key.
5. Verify that the GPG identities and Password Store expected by the new
   configuration have a tested restore source. On the personal Mac, confirm that
   `gpg --list-secret-keys --with-keygrip` includes the signing and SSH keys
   referenced by `users/bcmyers/security.nix`, and that
   `git -C ~/.password-store remote -v` names a reachable private remote. Stop
   if either check fails; the declarative configuration does not contain those
   private keys or encrypted password entries.
6. Download the official NixOS 26.05 x86_64 graphical ISO, verify its published SHA-256 checksum, and write it to a USB drive.

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
./scripts/nix-flake.sh flake check --all-systems --no-build --print-build-logs
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

The new installation has new SSH host keys and a new Tailscale identity. On the personal Mac, verify the new ED25519 host-key fingerprint against this local command:

```console
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Only after matching the fingerprint should the obsolete `known_hosts` entry be removed and the new one accepted.

The first Home Manager activation is expected to fail because it cannot decrypt
the shared Fish credentials until the dedicated ThinkPad age identity is
installed. The base NixOS system, local login, Tailscale, and the static SSH
authorized key remain available. After accepting the verified SSH host key,
run these commands on the personal Mac:

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
fish -ic 'set -q ANTHROPIC_API_KEY; and set -q TWILIO_SID; and set -q TWILIO_CLIENT_SECRET'
```

The final command checks only that all three variables exist; it does not print
their values. Never copy either age identity into the repository.

Restore the GPG material from its verified source before expecting signed Git
commits or GPG-backed SSH authentication to work. When the working source is
the personal Mac, an authenticated SSH stream avoids writing an unencrypted export to
disk:

```console
gpg --export --armor | ssh thinkpad 'gpg --import'
gpg --export-secret-subkeys --armor | ssh thinkpad 'gpg --import'
gpg --export-ownertrust | ssh thinkpad 'gpg --import-ownertrust'
```

Review the keys being exported first; these commands intentionally transfer the
personal Mac's complete GPG keyring. Never use the work Mac as the source. On
the ThinkPad, compare `gpg
--list-secret-keys --with-keygrip` with the declarative `sshKeys` list and prune
obsolete keygrips rather than copying unexplained entries forward.

Then restore Password Store from its existing private Git remote:

```console
git clone bcmyers@bcmyers.com:~/.password-store ~/.password-store
pass ls >/dev/null
```

Do not wipe the source machine or remove its GPG material until decryption, a
test signature, GPG-agent SSH authentication, and Password Store all succeed on
the ThinkPad.

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
- Wi-Fi, Ethernet, Tailscale, and SSH from the personal Mac
- Audio, Bluetooth, printing, keyboard, TrackPoint, touchpad, and brightness
- Suspend and resume several times
- Fish, Git/GPG signing, Neovim, tmux, Alacritty, and direnv
- SOPS-provided Fish variables exist without printing their values
- `just check`, `just build-thinkpad`, and `just switch-thinkpad`
- A previous NixOS generation from the systemd-boot menu

Hibernation is intentionally not configured. The 8 GiB swapfile is for memory pressure and can be resized declaratively later.

## 9. Routine updates

From the repository on the installed ThinkPad:

```console
git pull --ff-only
./scripts/nix-flake.sh flake update
just check
just build-thinkpad
just switch-thinkpad
```

Review and commit `flake.lock` updates from a branch rather than updating the running machine from an uncommitted lock file.
