# Install NixOS on the ThinkPad

This runbook replaces Pop!_OS and every partition on the ThinkPad's only internal drive. Nothing on the existing installation is retained.

Commands in this runbook assume Bash; run `bash` first when starting from Fish.

## Expected machine

- Lenovo ThinkPad X1 Extreme, model `20MF000CUS`
- Internal drive: `/dev/nvme0n1`
- Stable installation target: `/dev/disk/by-id/nvme-WDC_PC_SN720_SDAQNTW-512G-1001_184521422453`
- Expected serial: `184521422453`
- Expected size: approximately `476.9G`
- Expected model: `WDC PC SN720 SDAQNTW-512G-1001`
- UEFI boot with Secure Boot disabled

Stop if any of those facts differ. Never infer the target disk from device ordering alone when another internal disk is present.

## Chosen boot and availability policy

Keep LUKS2 encryption, retain a recovery passphrase, and unlock automatically
with the TPM after Secure Boot is configured. Initial boots still require the
passphrase: formatting and installing NixOS do not enroll the TPM or firmware.
Complete [Secure Boot, TPM enrollment, and the recovery tests](thinkpad-availability.md)
before relying on unattended operation. Keep that guide open on the Mac while
installing; the current Pop!_OS desktop and this Codex session will not survive
the replacement.

The old Pop!_OS encryption is erased. Choose a new recovery passphrase for the
new LUKS filesystem and store it somewhere accessible without this ThinkPad.
It is separate from the `bcmyers` login password. Never put it in Git or Nix.

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
   just test-thinkpad-boot
   ```

   `just test-disko` formats only a disposable virtual disk. It installs and boots the encrypted layout with a VM-only dummy key.

   On this Pop!_OS installation, `bcmyers` can access KVM but the Nix build
   users cannot. If the sandboxed test falls back to slow software emulation,
   build its driver and run it directly as `bcmyers` in a fresh temporary
   directory:

   ```console
   ./scripts/nix-flake.sh build '.#nixosConfigurations.thinkpad.config.system.build.installTest.driver' --out-link result-disko-driver
   test_driver="$(readlink -f result-disko-driver)/bin/nixos-test-driver"
   test_results="$(mktemp -d -t dotfiles-disko.XXXXXXXX)"
   (cd "$test_results" && XDG_RUNTIME_DIR="$test_results" "$test_driver" --no-interactive -o . --junit-xml junit.xml)
   ```

   This runs the same disposable-disk test without changing `/dev/kvm`
   permissions or operating on the physical SSD. Test logs and virtual disks
   remain in `$test_results` for inspection. The isolated runtime directory
   also prevents network-socket collisions between concurrent test runs.
   The same driver approach works for `.#thinkpad-boot-test.driver`.
5. Verify that the GPG identities and Password Store expected by the new
   configuration have a tested restore source. On the personal Mac, confirm that
   `gpg --list-secret-keys --with-keygrip` includes the personal encryption
   key and the signing key referenced by `users/bcmyers/identity.nix`. The
   ThinkPad uses a separate Ed25519 SSH key; it does not need the Mac's GPG
   primary secret key for SSH. Also confirm that the Password Store Git
   repository is available from its private remote or from the Mac itself. Stop
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

Test Wi-Fi or Ethernet, keyboard, TrackPoint, touchpad, audio, and brightness
before erasing the disk. The installed always-on profile disables sleep.

## 3. Get the configuration

Connect to the network and clone the reviewed revision:

```console
mkdir -p ~/lib
git clone https://github.com/bcmyers/dotfiles.git ~/lib/dotfiles
cd ~/lib/dotfiles
read -r -p 'Reviewed full commit SHA: ' reviewed_revision
[[ "$reviewed_revision" =~ ^[0-9a-f]{40}$ ]] || exit 1
git fetch origin "$reviewed_revision"
git switch --detach "$reviewed_revision"
./scripts/nix-flake.sh flake check --all-systems --no-build --print-build-logs
```

Use the commit that was actually built and reviewed, including the updated
lock file. Publish that commit before beginning installation; uncommitted
changes on the old system will not appear in this clone. The old `master`
branch does not contain this NixOS configuration.

## 4. Create the temporary LUKS password file

Disko reads the initial passphrase from a root-only file in the live environment's temporary filesystem:

```console
sudo install -m 600 /dev/null /tmp/secret.key
read -r -s -p 'New LUKS passphrase: ' LUKS_PASSWORD
printf '\n'
read -r -s -p 'Repeat LUKS passphrase: ' LUKS_CONFIRMATION
printf '\n'
if [[ -z "$LUKS_PASSWORD" || "$LUKS_PASSWORD" != "$LUKS_CONFIRMATION" ]]; then
  unset LUKS_PASSWORD LUKS_CONFIRMATION
  echo 'Passphrases must match and must not be empty.' >&2
  exit 1
fi
printf '%s' "$LUKS_PASSWORD" | sudo tee /tmp/secret.key >/dev/null
unset LUKS_PASSWORD LUKS_CONFIRMATION
```

This file exists only in live memory and is removed before reboot.

## 5. Final destructive gate

Run the inspection again immediately before Disko:

```console
lsblk -d -o NAME,PATH,SIZE,MODEL,SERIAL
lsblk -o NAME,PATH,TYPE,SIZE,FSTYPE,MOUNTPOINTS /dev/nvme0n1
```

Check that the stable target resolves to that same inspected drive:

```console
readlink -f /dev/disk/by-id/nvme-WDC_PC_SN720_SDAQNTW-512G-1001_184521422453
```

The next command irreversibly destroys the partition table, Pop!_OS recovery environment, current LUKS container, and all files on that drive:

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

## 6. Create signing keys, install, and set the local password

Lanzaboote refuses to install unsigned boot files. Create this machine's signing
keys inside the mounted encrypted root before running `nixos-install`. These
commands create keys on the SSD; they do not enroll firmware keys or enable
Secure Boot. Use only after the `/mnt` checks above succeed.

```console
sudo install -d -m 700 /mnt/var/lib/sbctl
printf '%s\n' \
  'keydir: /mnt/var/lib/sbctl/keys' \
  'guid: /mnt/var/lib/sbctl/GUID' | sudo tee /tmp/sbctl-installer.conf >/dev/null
sudo nix --extra-experimental-features "nix-command flakes" run .#sbctl -- \
  --config /tmp/sbctl-installer.conf create-keys
sudo rm /tmp/sbctl-installer.conf
```

Now install the signed system and choose the local login password:

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
with-anthropic true
with-twilio true
```

These commands verify that credentials are available without printing them.
They are supplied only to the named command, not exported into every Fish
session. See [the secrets guide](../secrets/README.md). Never copy either age
identity into the repository.

Restore the GPG material from its verified source before expecting signed Git
commits or Password Store decryption to work. When the working source is
the personal Mac, an authenticated SSH stream avoids writing an unencrypted export to
disk:

Export the personal identity's public key and secret subkeys. Its primary
secret key stays on the Mac; ThinkPad SSH does not use GPG-agent. The export
may prompt for the GPG passphrase on the Mac.

```console
gpg --export --armor 39EE837B09384924CB2A8B96A65C0C4DE57884B8 | ssh thinkpad 'gpg --import'
gpg --export-secret-subkeys --armor 39EE837B09384924CB2A8B96A65C0C4DE57884B8 | ssh thinkpad 'gpg --import'
```

On the ThinkPad, check `gpg --list-secret-keys --with-keygrip`, verify the full
fingerprint against the Mac, and set ownertrust for your own verified identity
with `gpg --edit-key 39EE837B09384924CB2A8B96A65C0C4DE57884B8 trust`. Import
additional identities only if the existing Password Store requires them.

Create and register the permanent ThinkPad SSH key using [the SSH
runbook](ssh.md#provision-the-thinkpad-key). The temporary Pop!_OS key is not
included in Nix and will be lost when its filesystem is erased. Authorize the
new public key on the Mac and GitHub, then test it before retiring the old one.

Restore Password Store over the verified SSH connection to the Mac:

```console
git clone macbook:.password-store ~/.password-store
pass ls >/dev/null
```

Once the permanent key is authorized on `bcmyers.com` and its host key is
independently verified, restore and test the original remote:

```console
git -C ~/.password-store remote set-url origin bcmyers@bcmyers.com:~/.password-store
git -C ~/.password-store ls-remote origin HEAD
```

Do not remove the source GPG material until decryption, a test signature, and
SSH authentication succeed on the ThinkPad. `pass ls` alone does not test
decryption: use `pass show --clip ENTRY` for a known entry in the graphical
session and verify that it decrypted successfully.

Clone the configuration into the newly installed user's home directory and
select the same reviewed commit used for installation:

```console
mkdir -p ~/lib
git clone https://github.com/bcmyers/dotfiles.git ~/lib/dotfiles
cd ~/lib/dotfiles
read -r -p 'Installed full commit SHA: ' reviewed_revision
[[ "$reviewed_revision" =~ ^[0-9a-f]{40}$ ]] || exit 1
git fetch origin "$reviewed_revision"
git switch --detach "$reviewed_revision"
```

Install the current stable Rust toolchain through the Nix-managed Rustup client:

```console
cd ~/lib/dotfiles
just rust-update
```

Rustup owns Rust itself so the compiler can move to a new stable release without waiting for either NixOS stable or nixpkgs-unstable. The Rustup client and the rest of the selected development tools remain pinned by this flake.

Codex CLI is already installed by NixOS. Run `codex login` and complete the
ChatGPT sign-in, then verify with `codex login status`. See
[Codex setup and updates](codex.md) for the declarative defaults and update
workflow.

## 8. Enable unattended boot and validate the installation

Follow [the Secure Boot and availability guide](thinkpad-availability.md).
Complete its firmware enrollment, TPM enrollment, recovery verification, and
power-return tests before considering this an unattended machine.

Before relying on the machine, test:

- COSMIC login and logout
- NVIDIA driver loading with `nvidia-smi`
- Wi-Fi, Ethernet, Tailscale, and SSH from the personal Mac
- Audio, Bluetooth, printing, keyboard, TrackPoint, touchpad, and brightness
- Lid closure and desktop idle do not suspend the installed machine
- Battery policy selects a clean power-off at 5%, with UPower running before login
- A cold boot reaches Tailscale and SSH without a disk prompt or local login
- The recovery passphrase still unlocks the disk when TPM unlocking is unavailable
- Fish, Git/GPG signing, Neovim, tmux, Alacritty, and direnv
- `with-anthropic true` and `with-twilio true` succeed without printing secrets
- Firefox, Chrome, Codex CLI login, and GitHub SSH authentication
- `systemctl --user status ssh-agent` and matching SSH behavior in GUI apps and Fish
- `just check`, `just build-thinkpad`, and `just switch-thinkpad`
- A previous NixOS generation from the systemd-boot menu

Hibernation is intentionally not configured. The 8 GiB swapfile is for memory pressure and can be resized declaratively later.

## 9. Consume reviewed updates

Routine activation consumes an already reviewed and committed lock file. The
installation starts at a detached commit. Fetch and select the next reviewed
commit explicitly, or attach to the branch where the changes were merged
before using `git pull --ff-only`. From the installed ThinkPad:

```console
git fetch origin
read -r -p 'Reviewed update commit SHA: ' reviewed_revision
[[ "$reviewed_revision" =~ ^[0-9a-f]{40}$ ]] || exit 1
git switch --detach "$reviewed_revision"
just check
just build-thinkpad
just switch-thinkpad
```

Do not run `flake update` in this workflow.

## 10. Prepare dependency updates for review

Create a branch on a development machine, update the lock file there, and test
before opening or updating a pull request:

```console
git switch -c update/nix-inputs-YYYY-MM-DD
just update
just check
just build-thinkpad
just build-vm
just test-disko
git diff -- flake.lock
```

Commit and review the resulting `flake.lock`. Activate it on the ThinkPad only
after that reviewed commit is merged or otherwise explicitly approved.

## 11. Recover or roll back

If the new system cannot boot normally, select a previous generation from the
systemd-boot menu. Once logged in, make that previous generation current:

```console
sudo nixos-rebuild switch --rollback
```

Return the repository to the corresponding known-good reviewed commit before
the next `just switch-thinkpad`; otherwise the next switch simply reapplies the
bad configuration. If the machine cannot reach a local shell, boot the NixOS
installer USB, unlock and mount the encrypted root, and repair it from the live
environment rather than repartitioning the disk.
