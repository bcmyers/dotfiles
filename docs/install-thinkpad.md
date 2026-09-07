# ThinkPad installation: everything to do from here

Follow this guide in order. Every command block says which computer to use.
You will replace Pop!_OS, install the reviewed NixOS system, restore your
credentials, and test encrypted unattended boot. The supporting documents
explain the design; you do not need to follow them separately.

For a later installation, also read the
[lessons and reusable helpers from the completed setup](thinkpad-install-lessons.md),
especially the interactive GPG restore method that replaces the old pipeline.

Quick navigation: [prepare](#1-keep-these-instructions-and-recovery-information-on-the-mac),
[boot the USB](#2-prepare-the-thinkpad-and-boot-the-existing-usb),
[install](#3-confirm-hardware-and-internet-access),
[restore access and credentials](#8-connect-the-installed-thinkpad-to-the-network-and-tailscale),
[Secure Boot](#14-back-up-the-new-signing-keys-then-enable-secure-boot),
[unattended boot](#15-enroll-the-tpm-and-test-automatic-disk-unlocking),
[recovery](#if-something-goes-wrong).

## 0. What is already done

As of 2026-09-05:

- The SanDisk USB contains the official NixOS 26.05 graphical Intel/AMD installer.
  Its checksum and the complete USB readback were verified. **Do not format
  the USB again.**
- The reviewed system commit is
  **`8cc8fdd09889b31df31135bce4fadbff6ec42cef`**. The commands below select it
  explicitly. Later documentation edits do not change that tested system.
- The system build, configuration evaluations, encrypted installation VM,
  Secure Boot/TPM boot tests, and secret scans passed.
- The Mac has the ThinkPad's age restore identity, its own SSH key, and the
  Password Store source. You still need to confirm you can unlock your GPG
  key and decrypt a password.
- The internal SSD still contains Pop!_OS. Firmware keys and the physical TPM
  have not been enrolled for NixOS.
- Codex CLI is included. The existing graphical Codex app and its browser
  integration are not yet packaged by this NixOS configuration; plan to use
  the CLI after installation and keep the Mac available for this conversation.

You do **not** need to download the installer or repeat the VM builds before
following this guide. No Pop!_OS data backup is planned, as agreed.

## 1. Keep these instructions and recovery information on the Mac

**On the Mac:**

1. Open [this guide on GitHub](https://github.com/bcmyers/dotfiles/blob/codex/linux-home-manager-refresh/docs/install-thinkpad.md).
   Save an offline copy or print it. Keep the Mac awake, on AC, and connected
   to the same Tailscale account.
2. Keep your Wi-Fi password, GitHub and ChatGPT sign-in methods, and GPG
   passphrase accessible on the Mac.
3. Choose a **new disk recovery passphrase** and save it in your password
   manager on the Mac, with a second copy independent of the ThinkPad.
   You will enter it in step 5. Also choose a separate `bcmyers` login password.
4. Plan to stay at the ThinkPad for the initial boots and firmware setup.
   The current desktop session and files on Pop!_OS will be erased. Continue
   reading on the Mac after rebooting the ThinkPad.

Open Terminal on the Mac and start Bash. All subsequent Mac command blocks
assume this same Bash session. If you open a new terminal later, run `bash`
again; step 9 explains how to recreate its SSH helpers.

```bash
bash
set -o pipefail
test -s "$HOME/Library/Application Support/sops/age/thinkpad-keys.txt" && echo "ThinkPad age identity present"
test -s "$HOME/.ssh/id_ed25519" && echo "Mac SSH key present"
test -s "$HOME/.password-store/.gpg-id" && echo "Password Store present"
gpg --list-secret-keys --with-subkey-fingerprint 39EE837B09384924CB2A8B96A65C0C4DE57884B8
```

Expect all three “present” messages. The GPG listing must contain the
encryption subkey `82081CF07E9C1664` and signing subkey `B86678B99457460F`.
A missing identity must be located before wiping Pop!_OS; Nix does not contain
these private keys.

Verify an existing password decrypts without displaying it:

```bash
read -r -p 'Existing Pass entry to test: ' pass_entry
pass show --clip "$pass_entry"
```

Enter the GPG passphrase if prompted. A successful clipboard copy confirms
decryption. Do not paste the password into this guide or chat.

## 2. Prepare the ThinkPad and boot the existing USB

**On the ThinkPad, still in Pop!_OS:**

Connect AC power. Check offered firmware updates in a terminal:

```bash
sudo fwupdmgr refresh
fwupdmgr get-updates
```

If updates are offered, review the device list and apply the Lenovo system
and Intel Management Engine updates with the firmware updater:

```bash
sudo fwupdmgr update
```

Complete its requested reboots before continuing; do not interrupt a firmware
update. If no updates are offered, continue.

1. Prefer wired Ethernet for installation if available.
2. Leave the prepared SanDisk USB attached. Unplug other external storage to
   make the target disk easier to identify.
3. Restart. Press **F12** repeatedly at the Lenovo logo. If necessary, press
   **Enter** at the startup interrupt prompt, then **F12**.
4. Choose the **UEFI SanDisk/USB** entry. At the NixOS menu choose the default
   graphical installer entry and wait for the live desktop.
5. If Pop!_OS starts, restart and choose the USB again. If Secure Boot blocks
   the USB, enter firmware with **F1**, disable Secure Boot, save with **F10**,
   and retry F12. Secure Boot stays disabled until step 14.

Close the automatic graphical installation wizard if it opens. Use the live
desktop and its terminal for the commands below; Disko will apply your
repository's exact disk layout. Do not also run the wizard's partitioner.

## 3. Confirm hardware and internet access

**On the ThinkPad, in a terminal in the live USB desktop:**

```bash
bash
cat /sys/class/dmi/id/product_name
cat /sys/class/dmi/id/product_version
lsblk -d -o NAME,PATH,SIZE,MODEL,SERIAL
test -d /sys/firmware/efi && echo UEFI || echo BIOS
```

Match all of these before proceeding:

| Check | Expected |
| --- | --- |
| Product name | `20MF000CUS` |
| Product version | `ThinkPad X1 Extreme` |
| Internal disk | `/dev/nvme0n1`, approximately `476.9G` |
| SSD model | `WDC PC SN720 SDAQNTW-512G-1001` |
| SSD serial | `184521422453` |
| Boot mode | `UEFI` |

The roughly 115 GiB SanDisk is the installer, **not** the installation target.
If the internal SSD, serial, or UEFI check differs, stop and inspect the
hardware rather than substituting another disk.

Connect through the desktop network menu. For ordinary password-protected
Wi-Fi, the terminal alternative is:

```bash
nmcli device wifi list
read -r -p 'Wi-Fi network name: ' wifi_ssid
sudo nmcli --ask device wifi connect "$wifi_ssid"
```

Enter the Wi-Fi password only at its prompt. Verify internet access:

```bash
curl -I https://github.com
curl -I https://cache.nixos.org
```

Check keyboard layout, TrackPoint, touchpad, brightness, audio, and network
operation in the live desktop. Your passphrase will be typed with a US
keyboard layout during normal boot.

## 4. Fetch the exact reviewed configuration

**ThinkPad, live USB terminal:**

If `git --version` says Git is missing, first run `nix-shell -p git`.
This opens another shell with Git available.

```bash
mkdir -p ~/lib
git clone https://github.com/bcmyers/dotfiles.git ~/lib/dotfiles
cd ~/lib/dotfiles
git switch --detach 8cc8fdd09889b31df31135bce4fadbff6ec42cef
git rev-parse HEAD
```

The last line must be the full commit above. Stay in `~/lib/dotfiles` through
step 7. Do not use the old `master` configuration or run `flake update`.

The revision has already passed the build and VM tests. Downloading packages
again in the live environment is expected; the Pop!_OS Nix store is not
automatically used by the installer.

## 5. Enter the new disk recovery passphrase

**ThinkPad, live USB terminal:**

This creates a root-only temporary file in live memory. It is not the login
password, and it will not be committed or copied into the installed system.

```bash
sudo install -m 600 /dev/null /tmp/secret.key
read -r -s -p 'New LUKS recovery passphrase: ' LUKS_PASSWORD
printf '\n'
read -r -s -p 'Repeat LUKS recovery passphrase: ' LUKS_CONFIRMATION
printf '\n'
if [[ -z "$LUKS_PASSWORD" || "$LUKS_PASSWORD" != "$LUKS_CONFIRMATION" ]]; then
  unset LUKS_PASSWORD LUKS_CONFIRMATION
  echo 'Passphrases must match and must not be empty.' >&2
  exit 1
fi
printf '%s' "$LUKS_PASSWORD" | sudo tee /tmp/secret.key >/dev/null
unset LUKS_PASSWORD LUKS_CONFIRMATION
```

If they do not match, the Bash shell exits. Open Bash again, return to
`~/lib/dotfiles`, and repeat this step. Do not continue with an empty key file.

## 6. Erase the internal SSD and create the encrypted layout

**ThinkPad, live USB terminal. This is the destructive step.**

The next Disko command removes **all** internal SSD partitions, Pop!_OS, its
recovery environment, and its old encryption. First inspect the target again:

```bash
lsblk -d -o NAME,PATH,SIZE,MODEL,SERIAL
readlink -f /dev/disk/by-id/nvme-WDC_PC_SN720_SDAQNTW-512G-1001_184521422453
sudo test -s /tmp/secret.key && echo "Recovery passphrase file is ready"
```

The stable path must resolve to the inspected internal `/dev/nvme0n1` with
serial `184521422453`, and the “ready” message must appear. Then run:

```bash
sudo nix --extra-experimental-features "nix-command flakes" run .#disko -- \
  --mode destroy,format,mount \
  --flake '.#thinkpad'
```

**Wait for success before the next block.** Confirm the new mounts:

```bash
findmnt --mountpoint /mnt
findmnt --mountpoint /mnt/boot
lsblk -o NAME,PATH,TYPE,SIZE,FSTYPE,MOUNTPOINTS /dev/nvme0n1
```

Expect an ext4 root on `/dev/mapper/cryptroot` at `/mnt` and a vfat EFI
partition at `/mnt/boot`. The layout also provides an encrypted 64 GiB swapfile.

If formatting or mounting fails, inspect the error. Do not move on to
installation without both mounts, and do not rerun this destructive command
later as a repair procedure.

## 7. Create signing keys, install NixOS, and set the login password

**ThinkPad, live USB terminal, still in `~/lib/dotfiles`:**

Create this machine's Secure Boot signing keys inside the mounted encrypted
root. This step does not enroll firmware keys or change firmware settings.

```bash
sudo install -d -m 700 /mnt/var/lib/sbctl
printf '%s\n' \
  'keydir: /mnt/var/lib/sbctl/keys' \
  'guid: /mnt/var/lib/sbctl/GUID' | sudo tee /tmp/sbctl-installer.conf >/dev/null
sudo nix --extra-experimental-features "nix-command flakes" run .#sbctl -- \
  --config /tmp/sbctl-installer.conf create-keys
sudo rm /tmp/sbctl-installer.conf
```

After key creation succeeds, install:

```bash
sudo nix --extra-experimental-features "nix-command flakes" run .#nixos-install -- \
  --flake '.#thinkpad' \
  --no-root-passwd
```

Allow downloads and compilation to finish. If the network drops, restore it
and rerun **this installation command**, retaining the mounts and signing
keys. Do not rerun Disko or regenerate the signing keys to retry a download.

After installation reports success, set the normal user's password:

```bash
sudo nixos-enter --root /mnt -c 'passwd bcmyers'
```

Enter the separate login password twice. There is no root-password setup;
`bcmyers` uses this login password for `sudo`. Do not reboot until `passwd`
reports success.

Clean up and shut down:

```bash
sudo rm -f /tmp/secret.key
sync
sudo poweroff
```

Wait until fully off, remove the USB, and turn the ThinkPad on. Keep the USB
nearby for recovery. Enter the **disk recovery passphrase** at the disk prompt,
then log into COSMIC as **bcmyers** using the **login password**.

If the graphical login does not appear, try **Ctrl+Alt+F2**, log in as
`bcmyers`, and inspect `systemctl --failed`. Recovery steps are at the end.

## 8. Connect the installed ThinkPad to the network and Tailscale

**ThinkPad, installed NixOS, in a local terminal:**

Start Bash in each new terminal for this guide:

```bash
bash
hostname
cat /etc/os-release
```

Expect `thinkpad` and NixOS. The live USB's Wi-Fi connection is not
automatically carried over. Connect Ethernet or configure Wi-Fi again:

```bash
nmcli device wifi list
read -r -p 'Wi-Fi network name: ' wifi_ssid
sudo nmcli --ask device wifi connect "$wifi_ssid"
nmcli -f NAME,TYPE,AUTOCONNECT connection show
```

For Wi-Fi, use the saved Wi-Fi connection name shown above:

```bash
read -r -p 'Saved Wi-Fi connection name: ' wifi_profile
sudo nmcli connection modify "$wifi_profile" connection.permissions "" connection.autoconnect yes
sudo nmcli --ask connection up "$wifi_profile"
```

Creating it with `sudo nmcli` and allowing all users makes it available before
desktop login. Step 16 tests that this actually works. Do not put the Wi-Fi
password into Git or Nix configuration.

Bring Tailscale online:

```bash
sudo tailscale up
tailscale ip -4
tailscale status
systemctl is-active tailscaled sshd
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Open the printed Tailscale login URL in a browser and use your existing
tailnet account. Record the new **100.x.y.z address** and **ED25519 host-key
fingerprint** on the Mac. Approve the device if your tailnet requires it.

SSH is intentionally reachable through Tailscale, with public-key login.
The Mac's existing Ed25519 public key is already authorized. Password SSH and
root SSH are disabled.

A Home Manager activation failure is expected until step 10 restores its age
identity. The base OS, local login, SSH, and Tailscale remain usable.

## 9. Establish verified Mac-to-ThinkPad SSH

**Mac, in its Bash terminal:**

Enter the new Tailscale IP from the ThinkPad screen. Using the IP avoids
confusing the old Pop!_OS device with the new one.

```bash
read -r -p 'New ThinkPad Tailscale IPv4 address: ' THINKPAD_IP
ssh-keyscan -t ed25519 "$THINKPAD_IP" 2>/dev/null | ssh-keygen -lf -
```

**Compare the SHA256 fingerprint with the one displayed locally on the
ThinkPad in step 8.** A key scan alone is not proof of identity. Stop on a
mismatch. After matching it, remove only the old ThinkPad canonical trust entry:

```bash
ssh-keygen -R thinkpad.bilby-allosaurus.ts.net
```

Define two helpers that use the verified new IP and the Mac's established key:

```bash
tp_ssh() {
  ssh -F /dev/null \
    -o IdentitiesOnly=yes -o IdentityAgent=none \
    -o HostKeyAlias=thinkpad.bilby-allosaurus.ts.net \
    -i "$HOME/.ssh/id_ed25519" "bcmyers@$THINKPAD_IP" "$@"
}
tp_scp() {
  scp -F /dev/null \
    -o IdentitiesOnly=yes -o IdentityAgent=none \
    -o HostKeyAlias=thinkpad.bilby-allosaurus.ts.net \
    -i "$HOME/.ssh/id_ed25519" "$@"
}
tp_ssh 'hostname'
```

Accept the key only if the displayed fingerprint still matches. Expect
`thinkpad` as output. If you start a new Mac terminal, run `bash`, re-enter
`THINKPAD_IP`, and redefine these helpers; you do not need to remove the trust
entry again.

## 10. Restore Home Manager's age identity

**Mac, using the helpers above:**

```bash
tp_ssh 'install -d -m 700 ~/.config/sops/age'
tp_scp "$HOME/Library/Application Support/sops/age/thinkpad-keys.txt" \
  "bcmyers@$THINKPAD_IP:.config/sops/age/keys.txt"
tp_ssh 'chmod 600 ~/.config/sops/age/keys.txt'
```

**ThinkPad, local terminal:**

```bash
sudo systemctl restart home-manager-bcmyers.service
systemctl status home-manager-bcmyers.service --no-pager
```

Expect a successful activation; this oneshot service may show
`active (exited)`. If it fails, inspect its journal before continuing:

```bash
journalctl -u home-manager-bcmyers.service -b --no-pager -n 80
```

Close the terminal and open a new one so Fish gets the activated environment.
Run `bash` again, then:

```bash
with-anthropic true
with-twilio true
systemctl --user status ssh-agent --no-pager
```

Both credential checks should exit successfully without displaying a secret.
Do not print the decrypted files. These commands supply credentials only to
the selected child command.

## 11. Create the permanent ThinkPad SSH key and enable GitHub access

**ThinkPad, installed NixOS:**

```bash
install -d -m 700 ~/.ssh
ls -l ~/.ssh/id_ed25519_thinkpad*
```

“No such file” is expected on a fresh installation. If a key already exists,
do not overwrite it. Otherwise create it with a **nonempty passphrase**:

```bash
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519_thinkpad -C bcmyers@thinkpad
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
ssh-add ~/.ssh/id_ed25519_thinkpad
ssh-keygen -lf ~/.ssh/id_ed25519_thinkpad.pub
```

**Mac:** retrieve only the public key and authorize it for the Mac account:

```bash
install -d -m 700 ~/.ssh
tp_scp "bcmyers@$THINKPAD_IP:.ssh/id_ed25519_thinkpad.pub" ~/.ssh/thinkpad-nixos.pub
ssh-keygen -lf ~/.ssh/thinkpad-nixos.pub
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
if ! grep -qxF "$(cat ~/.ssh/thinkpad-nixos.pub)" ~/.ssh/authorized_keys; then
  printf '\n' >> ~/.ssh/authorized_keys
  cat ~/.ssh/thinkpad-nixos.pub >> ~/.ssh/authorized_keys
fi
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

The retrieved public-key fingerprint must match the ThinkPad's output.
Record the Mac's host fingerprint from the last command.

**ThinkPad:**

```bash
ssh macbook true
```

Compare the Mac's offered ED25519 fingerprint with its local output before
accepting it. If it offers a different key type, get that type's fingerprint
on the Mac and compare it; do not accept an unverified host key.

**On GitHub, in the Mac browser:**

1. Open [Settings → SSH and GPG keys](https://github.com/settings/keys).
2. Select **New SSH key**, type **Authentication Key**, and use a title such
   as **ThinkPad NixOS 2026-09**.
3. Copy the public key on the Mac with `pbcopy < ~/.ssh/thinkpad-nixos.pub`
   and paste it into GitHub. Save it, completing account verification.

[GitHub's SSH-key instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

**ThinkPad:**

```bash
ssh -T git@github.com
gh auth login --hostname github.com --git-protocol ssh --web --skip-ssh-key
gh auth status
```

GitHub SSH should greet **bcmyers** and say authentication succeeded. Its exit
status is 1 because GitHub does not offer a shell. GitHub CLI sign-in is a
separate browser flow; use the OS credential store when offered and inspect
any warning about plaintext token storage. [GitHub CLI authentication](https://cli.github.com/manual/gh_auth_login).

The SSH agent keeps an unlocked key for two hours. After a reboot you may
need `ssh-add ~/.ssh/id_ed25519_thinkpad` for **outbound** Git/SSH operations.
This does not stop **inbound** Mac-to-ThinkPad SSH from working unattended.

For other computers, the host aliases and usernames are already managed by
Home Manager. Authorize this same public key on each destination where needed.
Use its existing working login or management path; if its authorized keys are
managed by Nix, add the public key to that machine's configuration and rebuild.
Test each destination before removing old keys. The old Pop!_OS bootstrap
fingerprint is `SHA256:8vrdYfLTSqvY3oiD2wSvIY+ZA8TRuE0GcDK4Jzyk+/E`.
Do not revoke unrelated historical keys.

## 12. Restore GPG, Password Store, and the configuration checkout

**Mac, still in Bash with the SSH helpers:**

```bash
set -o pipefail
cd ~/lib/dotfiles
THINKPAD_HOST="$THINKPAD_IP" bash scripts/restore-thinkpad-gpg.sh
```

The export may prompt for the GPG passphrase on the Mac. The primary secret
key stays on the Mac; only secret subkeys are restored to the ThinkPad.
Do not save an unencrypted export into the repository.

**ThinkPad:**

```bash
export GPG_TTY="$(tty)"
gpg --list-secret-keys --with-subkey-fingerprint 39EE837B09384924CB2A8B96A65C0C4DE57884B8
gpg --edit-key 39EE837B09384924CB2A8B96A65C0C4DE57884B8 trust
```

Compare the full fingerprint with the Mac. For **your own verified identity**,
select **5 (ultimate)**, confirm, then type `quit` if left at the GPG prompt.
A `sec#` primary-key stub is expected when only subkeys were imported.

Restore the password repository:

```bash
git clone macbook:.password-store ~/.password-store
pass ls >/dev/null
read -r -p 'Existing Pass entry to test: ' pass_entry
pass show --clip "$pass_entry"
```

The clipboard copy must decrypt successfully; `pass ls` alone is insufficient.
If an entry needs another identity, restore its verified subkeys from the Mac
in the same way.

Test the signing subkey without creating a repository commit:

```bash
printf 'ThinkPad signing test\n' |
  gpg --local-user B86678B99457460F --clearsign |
  gpg --verify
```

Expect a good signature for the verified identity. Next clone the system
configuration into the new home directory:

```bash
mkdir -p ~/lib
git clone git@github.com:bcmyers/dotfiles.git ~/lib/dotfiles
cd ~/lib/dotfiles
git switch --detach 8cc8fdd09889b31df31135bce4fadbff6ec42cef
git rev-parse HEAD
just install-hooks
just rust-update
```

The clone used in the live installer was temporary; this is your permanent
checkout. The CLI and other Nix packages are already installed. Rustup downloads
the current stable Rust toolchain on this explicit first-use step.

Password Store initially keeps the Mac as its remote, which is enough to use
and sync passwords. If you also want the original `bcmyers.com` remote, first
authorize the new ThinkPad public key there through your existing management
path and verify that server's SSH host fingerprint. Then:

```bash
git -C ~/.password-store remote set-url origin bcmyers@bcmyers.com:~/.password-store
git -C ~/.password-store ls-remote origin HEAD
```

If that server is unavailable, keep the working Mac remote; do not delete the
password store or its source.

## 13. Sign in to Codex and restore browser state

**ThinkPad, local desktop terminal:**

```bash
cd ~/lib/dotfiles
codex --version
codex login
codex login status
codex
```

Complete the ChatGPT browser sign-in. For an SSH-only session,
`codex login --device-auth` is an alternative if device-code login is enabled
in your ChatGPT security settings. [Official Codex authentication](https://learn.chatgpt.com/docs/auth).

Codex CLI runs as the normal `bcmyers` user. This configuration does not
install or migrate the current graphical desktop app, its local sessions, or
its browser-control integration. Use the installed CLI to continue working;
graphical NixOS compatibility remains separate work. Plugin connections may
need signing in again. Do not put tokens or `auth.json` into Git.

Open Firefox and Chrome and sign into the accounts you want restored.
[Firefox Sync](https://support.mozilla.org/en-US/kb/how-do-i-set-sync-my-computer)
can restore your existing Firefox data. Enable only the
[Chrome sync categories](https://support.google.com/chrome/answer/165139)
you want; syncing old Chrome bookmarks could repopulate the clean slate.
No one-way Firefox-to-Chrome bookmark synchronization has been configured by
this NixOS setup.

## 14. Back up the new signing keys, then enable Secure Boot

**ThinkPad, local terminal:**

Make an encrypted archive of the new machine's signing keys. Choose a separate
archive passphrase and record it in the password manager on the Mac.

```bash
set -o pipefail
export GPG_TTY="$(tty)"
sudo tar -C /var/lib -cf - sbctl |
  gpg --symmetric --cipher-algo AES256 --output "$HOME/thinkpad-secure-boot-keys.tar.gpg"
```

**Mac:**

```bash
mkdir -p ~/Documents/ThinkPad-recovery
tp_scp "bcmyers@$THINKPAD_IP:thinkpad-secure-boot-keys.tar.gpg" ~/Documents/ThinkPad-recovery/
gpg --decrypt ~/Documents/ThinkPad-recovery/thinkpad-secure-boot-keys.tar.gpg |
  tar -tf - >/dev/null
```

Enter the archive passphrase and confirm the command succeeds. Keep that
encrypted archive and your disk recovery passphrase available off the ThinkPad.

**ThinkPad, local terminal:**

```bash
sudo sbctl status
sudo sbctl verify
```

Expect `EFI/BOOT/BOOTX64.EFI`, `EFI/systemd/systemd-bootx64.efi`, and
`EFI/Linux/nixos-generation-*.efi` to be signed. Detached `kernel-*` and
`initrd-*` files are authenticated by their hashes in the signed entry;
an unsigned report for those is not itself a failure. Investigate unsigned
bootloader or generation entries.

Restart into firmware (**F1** at the Lenovo logo):

1. Set **Config → Power → Power On with AC Attach → Enabled**.
2. Set a **supervisor password** and save it outside the ThinkPad. Do not set
   a power-on or drive password; those would require typing during each boot.
3. Under **Security → Secure Boot**, enable Secure Boot and select
   **Reset to Setup Mode**. Preserve the forbidden-signature database
   (`dbx`); do not select **Clear All Secure Boot Keys**. If the menu differs,
   inspect it before making a different key change.
4. Save with **F10**, boot NixOS, enter the disk passphrase, and log in.

This follows the [Lanzaboote ThinkPad procedure](https://github.com/nix-community/lanzaboote/blob/v1.1.0/docs/getting-started/enable-secure-boot.md)
and the [Lenovo firmware controls](https://download.lenovo.com/pccbbs/mobiles_pdf/p1_x1extreme_ug_en.pdf).

**ThinkPad, local terminal:**

```bash
bash
sudo sbctl status
```

It must report **Setup Mode enabled**. Then enroll the generated keys along
with Microsoft keys for compatibility with firmware/Option ROMs:

```bash
sudo sbctl enroll-keys --microsoft
sudo reboot
```

If sbctl rejects an unsafe enrollment, stop and inspect the reason. Do not use
its force/bricking override.

After reboot, enter the disk passphrase again, log in, open Bash, and verify:

```bash
bootctl status
sudo sbctl status
sudo systemd-analyze condition ConditionSecurity=uefi-secureboot
sudo systemd-analyze condition ConditionSecurity=measured-uki
nvidia-smi
```

Secure Boot must show **enabled (user)**; both condition checks must succeed.
Confirm the display and NVIDIA driver work before TPM enrollment.

## 15. Enroll the TPM and test automatic disk unlocking

**ThinkPad, local terminal:**

```bash
cd ~/lib/dotfiles
sudo ./scripts/enroll-thinkpad-tpm.sh
```

The helper checks this exact machine, SSD, mounted root, Secure Boot, and
Lanzaboote. It asks you to prove the recovery passphrase works, then enrolls
the TPM. It may ask for the passphrase again. Password recovery is retained;
only older TPM enrollment slots are replaced.

This ThinkPad uses a compatible PCR 0+7 policy without a PIN. Firmware or
Secure Boot key changes can require passphrase recovery. The technical
rationale is in [the availability reference](thinkpad-availability.md).

Reboot while you are present:

```bash
sudo reboot
```

Expect the COSMIC login screen **without a disk-password prompt**.
Do not log into the desktop yet.

**Mac:**

```bash
tp_ssh 'hostname'
tp_ssh 'systemctl is-active tailscaled sshd upower'
tp_ssh 'loginctl show-user bcmyers -p Linger'
tp_ssh 'systemctl --failed --no-pager'
```

Expect `thinkpad`, three `active` results, `Linger=yes`, and no unexplained
failed units. If the disk still asks for a password, use the recovery
passphrase and inspect the error; do not erase the disk or clear the TPM.

Unattended boot provides OS services and inbound SSH. It does not unlock
the passphrase-protected outbound SSH key, resume Codex work, or automatically
start a Codex job.

## 16. Finish Tailscale naming and test power recovery

**Mac, in the [Tailscale Machines page](https://login.tailscale.com/admin/machines):**

1. Identify the new NixOS device by the IP recorded in step 8.
2. If the old offline Pop!_OS device holds the name `thinkpad`, rename that
   old entry to `thinkpad-pop-os-retired`. Name the new device `thinkpad`.
   Do not remove or rename another computer.
3. The device menu's **Disable key expiry** option can prevent this always-on
   machine from later requiring a Tailscale reauthentication. Use it for the
   new ThinkPad if you accept that its device authorization will remain valid
   until you revoke it. Keep the normal tailnet access policy in place.
   [Device names](https://tailscale.com/docs/concepts/machine-names) and
   [key expiry](https://tailscale.com/docs/features/access-control/key-expiry).

Then try the canonical hostname, using the already verified key:

```bash
ssh -F /dev/null -o IdentitiesOnly=yes -o IdentityAgent=none \
  -i "$HOME/.ssh/id_ed25519" bcmyers@thinkpad.bilby-allosaurus.ts.net hostname
ssh thinkpad
```

If the canonical command works but the short alias does not, inspect
`ssh -G thinkpad` on the Mac: its hostname must be
`thinkpad.bilby-allosaurus.ts.net` and user `bcmyers`. Keep using the canonical
command or `tp_ssh` until the Mac's Home Manager SSH configuration is applied.
Do not disable host checking to hide a mismatch.

**At the ThinkPad, with the Mac available to test SSH:**

1. Leave it at the greeter, close the lid on AC, and confirm `tp_ssh hostname`
   still works.
2. Briefly unplug AC while it runs on battery and repeat the SSH check.
   The router/access point must also have power for network access.
3. While on battery, shut down **cleanly** with `sudo poweroff`. Wait until
   completely off. Reattach AC: it should power on and return to SSH without
   typing at the ThinkPad. This tests the firmware setting without cutting a
   live disk write.
4. Check `cat /etc/UPower/UPower.conf`: action level is 5% and the critical
   action is PowerOff. Validate low-battery behavior while physically present
   before relying on it; a degraded battery can drop abruptly.
5. Test recovery once: disable Secure Boot in firmware, boot with the recovery
   passphrase, then re-enable Secure Boot and verify automatic unlock returns.
   Do **not** rerun TPM enrollment while Secure Boot is disabled.

## 17. Perform the final checks and a normal rebuild

**ThinkPad, installed desktop:**

- Log into and out of COSMIC.
- Check Wi-Fi/Ethernet, audio, Bluetooth, printing if used, TrackPoint,
  touchpad, brightness, Firefox, and Chrome.
- Check `nvidia-smi`, `codex login status`, `gh auth status`,
  `ssh -T git@github.com`, and `ssh macbook true`.
- Verify a Pass entry decrypts and GPG produces a good signature.
- Confirm `with-anthropic true` and `with-twilio true` succeed.
- Confirm lid closure and idle do not suspend the system.

Then, in Bash:

```bash
cd ~/lib/dotfiles
just check
just build-thinkpad
just switch-thinkpad
systemctl --failed --no-pager
sudo sbctl verify
sudo reboot
```

Confirm automatic unlock and Mac SSH still work after the rebuild. Save the
working system revision and recovery information on the Mac. Only then retire
the old Pop!_OS Tailscale entry and old ThinkPad bootstrap-key authorizations.

**Installation is complete when:** NixOS starts from the SSD, secrets and
developer tools work, Secure Boot is enabled, the recovery passphrase works,
and power-on with AC returns the machine to SSH without a local login.

## If something goes wrong

**A download or install fails before the first reboot:** restore networking
and rerun the step 7 `nixos-install` command while the existing root and EFI
partitions remain mounted. Do not repartition.

**TPM unlock fails:** enter the saved disk recovery passphrase. After an
expected firmware/trust change, verify Secure Boot and rerun the helper from
the installed system. Investigate unexplained changes before re-enrolling.

**A later NixOS update will not boot:** hold **Space** during startup to expose
the systemd-boot menu, and try a previous retained generation. Once logged in:

```bash
sudo nixos-rebuild switch --rollback
```

Return `~/lib/dotfiles` to the corresponding known-good commit before the next
rebuild. The initial installation has no older known-good NixOS generation.

**No installed generation boots:** disable Secure Boot temporarily, boot the
same USB with F12, connect to the network, open Bash, and mount the existing
system for repair:

```bash
sudo cryptsetup open /dev/disk/by-partlabel/disk-main-cryptroot cryptroot
sudo mount /dev/mapper/cryptroot /mnt
sudo mount /dev/disk/by-partlabel/disk-main-ESP /mnt/boot
sudo nixos-enter --root /mnt
```

You are now in the installed system as root. For a repair using the known-good
configuration already cloned in step 12:

```bash
cd /home/bcmyers/lib/dotfiles
git -c safe.directory=/home/bcmyers/lib/dotfiles rev-parse HEAD
nixos-rebuild boot --flake '.#thinkpad'
exit
sudo reboot
```

If failure happened before step 12, fetch the reviewed repository in the live
environment using step 4, then rerun step 7's `nixos-install` command against
the already mounted filesystems, retaining `/mnt/var/lib/sbctl`. Do not recreate
keys that already exist. Remove the USB and re-enable Secure Boot before
testing normal TPM unlock again.

**Never run Disko's destroy/format command to repair an installed system.**

## Later updates

Your checkout starts at a detached, tested commit. For an already reviewed
update, use its actual full SHA:

```bash
cd ~/lib/dotfiles
git fetch origin
read -r -p 'Reviewed update commit SHA: ' reviewed_revision
[[ "$reviewed_revision" =~ ^[0-9a-f]{40}$ ]] || exit 1
git switch --detach "$reviewed_revision"
just check
just build-thinkpad
just switch-thinkpad
```

For a new dependency upgrade, make a review branch, run `just update` there,
then review and build it. Test both `just test-disko` and
`just test-thinkpad-boot` when changing the boot/storage path. Commit the lock
file before installing the reviewed update. Keep the recovery passphrase and
local access available for firmware or Secure Boot trust changes.

The [NixOS installation manual](https://nixos.org/manual/nixos/stable/#sec-installation-manual)
is the upstream reference; the commands above apply this repository's specific
disk layout and tested revision.

### Retaining reviewed builds before installation

Use distinct result links for the system and portal test. `just build-thinkpad`
keeps `result-thinkpad`; `just test-cosmic-remote-desktop` keeps
`result-cosmic-remote-desktop`. Keep those links until installation and testing
are complete. Do not use `--no-link` for a build that must survive an unattended
handoff: scheduled garbage collection can delete even a freshly compiled
system if nothing retains it. See the [Nix build reference](https://nix.dev/manual/nix/2.35/command-ref/new-cli/nix3-build.html) for result-link options.

The interactive `scripts/upgrade-thinkpad-desktop.sh` helper builds a clean,
committed revision and keeps separate system and test roots under
`~/.local/state/thinkpad-install/builds/<revision>/`. It retains the successful
system before starting the portal test and installs that same revision for the
next boot. It requires the 64 GiB swap file to be active before building and
permits two packages at a time, with three compiler threads per package.

On machines installed with the earlier 8 GiB swap file, changing its declared
size does not immediately resize the active file. Expand and activate it before
retrying a large build; verify the live size with `swapon --show`. Do not run
Disko again to make this change. The small Disko test VM continues to use a
1 GiB swap file.

To resize the existing ThinkPad swap file from the Mac, with the reviewed
checkout synchronized on both machines, run:

```bash
bash ~/lib/dotfiles/scripts/resize-thinkpad-swap.sh
```

The helper prompts for the ThinkPad sudo password, checks that the target is
the existing root-owned swap file on encrypted ext4, and requires an idle
compiler, available RAM, and free disk space. It activates an 8 GiB temporary
swap file before resizing the original to 64 GiB, verifies the larger file is
active, then removes the temporary file. If a step fails, it retains active
temporary swap for recovery. It neither compiles nor installs a configuration.
Install the new NixOS generation before rebooting: the old generation can
recreate its old 8 GiB file at startup. Allocation and activation follow the
[util-linux swap-file guidance](https://github.com/util-linux/util-linux/blob/master/sys-utils/swapon.8.adoc).
