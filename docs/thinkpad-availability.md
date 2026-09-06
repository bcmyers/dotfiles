# ThinkPad unattended boot and recovery

The chosen setup keeps LUKS2 encryption and a recovery passphrase. Once the
physical setup below is complete, the TPM unlocks the root filesystem without
a PIN, NixOS starts NetworkManager and Tailscale, and SSH becomes available
without a desktop login. The recovery passphrase remains usable independently
of the TPM. Installing the configuration alone does not complete enrollment.

The ThinkPad's TPM supports SHA-256 but lacks `PolicyAuthorizeNV`: the target
systemd 260.2 tool reports `obsolete` for `systemd-pcrlock is-supported`.
Consequently, we do not enable Lanzaboote's `measuredBoot` policy manager.
Instead, `systemd-cryptenroll` seals against **PCR 0 and PCR 7, using SHA-256**:

- PCR 0 covers firmware code. Firmware updates may require recovery.
- PCR 7 covers Secure Boot policy and signing authorities. Changing firmware
  keys or disabling Secure Boot prevents ordinary automatic unlocking.
- Routine NixOS generations retain the signing authority, so kernel/initrd
  updates do not intentionally invalidate this policy. Test after updates.

Lanzaboote 1.1.0 signs the boot entry and checks the hashes of the kernel and
initrd. With Secure Boot active, its stub uses the signed, embedded command
line rather than a command line supplied by a modified boot entry. Do not
enroll with Secure Boot disabled, use an empty PCR list, or place an unlock key
in `/boot`, the initrd, Git, or the Nix store. A PIN is deliberately omitted to
permit unattended recovery; this is not equivalent to a human approving each
boot and does not protect data from a compromised running OS or every attack
using previously trusted software.

## 1. Install and keep recovery material available

Complete [installation](install-thinkpad.md) and verify a normal boot using
the recovery passphrase. Leave Secure Boot disabled during USB installation.
The installer creates machine-specific signing keys under `/var/lib/sbctl`
on the encrypted SSD. Nothing enrolls firmware keys automatically.

Store the LUKS recovery passphrase in your password manager on the Mac, and
keep another recovery copy independent of this laptop. Verify that you can
retrieve it before proceeding. Your normal `bcmyers` password cannot unlock
LUKS unless you independently chose the same text; use different passwords.

Back up the Secure Boot keys through your existing encrypted backup process.
They allow signing future generations and must remain private. Optionally make
a LUKS header backup with `cryptsetup luksHeaderBackup` and store it securely
off the ThinkPad. A header backup preserves old keyslots: replacing a password
does not revoke one embedded in an older header backup.

## 2. Enable Secure Boot on the installed ThinkPad

Connect AC power and keep the USB available for recovery. From NixOS:

```console
sudo sbctl status
sudo sbctl verify
```

Check that `EFI/BOOT/BOOTX64.EFI`, `EFI/systemd/systemd-bootx64.efi`, and the
`EFI/Linux/nixos-generation-*.efi` entries are signed. Detached `kernel-*`
files can be reported as unsigned: their hashes are authenticated by the
signed Lanzaboote entry. Unexpected unsigned boot entries need investigation.

Restart into firmware settings (F1 at the ThinkPad logo):

1. Set **Config → Power → Power On with AC Attach → Enabled**.
2. Set a **supervisor password** and save it outside the ThinkPad. This protects
   firmware settings. Do not enable a power-on password or drive password,
   because those require someone at the keyboard during boot.
3. Under **Security → Secure Boot**, enable Secure Boot and select **Reset to
   Setup Mode**, following Lanzaboote's ThinkPad procedure. Preserve the
   forbidden-signature database (`dbx`); do not select **Clear All Secure Boot
   Keys**. If the firmware differs from these instructions, stop and inspect it.
4. Save with F10 and boot the installed NixOS system, entering the LUKS
   recovery passphrase.

Check `sudo sbctl status`: it must show Setup Mode enabled before enrollment.
Then enroll your generated keys together with Microsoft keys, which can be
required by the NVIDIA firmware/Option ROMs:

```console
sudo sbctl enroll-keys --microsoft
sudo reboot
```

Do not bypass an Option ROM safety rejection with sbctl's force/bricking flag.
After reboot, use the LUKS passphrase again and verify:

```console
bootctl status
sudo sbctl status
sudo systemd-analyze condition ConditionSecurity=uefi-secureboot
sudo systemd-analyze condition ConditionSecurity=measured-uki
```

Secure Boot must be **enabled (user)**, and both condition checks must succeed.
Verify graphics and the display still work before enrolling the disk.

## 3. Enroll the TPM without deleting password recovery

In your checked-out repository on the installed ThinkPad, run:

```console
sudo ./scripts/enroll-thinkpad-tpm.sh
```

The helper checks the machine, internal SSD, mounted encrypted root, Secure
Boot, and Lanzaboote. It first prompts for the recovery passphrase and checks
it with external tokens disabled. It then prompts as necessary to enroll a
new TPM slot, bound to PCRs 0+7 with no PIN. Only old TPM slots are replaced;
password slots remain. Never run this helper from Pop!_OS or the live USB.

Reboot while physically present. A successful setup reaches the greeter with
no disk prompt. From the Mac, connect over Tailscale **before logging in
locally**:

```console
ssh thinkpad
systemctl is-active tailscaled sshd upower
loginctl show-user bcmyers -p Linger
systemctl --failed
```

The desktop can remain at its login screen. `bcmyers`'s service manager starts
at boot through systemd lingering. The Home Manager SOPS identity must already
have been restored for user secrets to work. NetworkManager Wi-Fi profiles
must connect for the whole system without a GUI keyring prompt; wired Ethernet
is the simpler first test.

Codex CLI is installed, but this does not automatically start a Codex session,
resume interrupted work, or sign into the graphical Codex app. Specific
unattended jobs need explicit services and restart policies when added.

## 4. Test power recovery and sleep policy

The configuration ignores lid closure and idle, disables suspend/hibernate,
starts UPower without a desktop login, and powers off cleanly at 5% battery.
It uses the battery through short outages rather than immediately sleeping.

Test these cases before depending on remote availability:

1. Close the lid on AC and confirm repeated SSH connections still work.
2. Disconnect AC briefly and check SSH while running on battery. Router and
   access-point power determine whether the network remains reachable.
3. While on battery, shut the laptop down cleanly. Reattach AC and verify it
   powers on and returns to SSH without typing anything. This tests power
   recovery without deliberately exhausting the battery or cutting a disk write.
4. Check low-battery settings with `cat /etc/UPower/UPower.conf`. Validate actual
   battery behavior under supervision; a degraded battery can drop abruptly.
5. Test a normal NixOS rebuild followed by reboot before leaving it unattended.

The ThinkPad battery reported 54.75 Wh full capacity against 80.4 Wh design
capacity on 2026-09-05. This provides a buffer, not a guaranteed outage runtime.

## 5. Recovery and maintenance

**If automatic unlocking fails:** enter the saved LUKS passphrase at the
console. After a planned firmware or Secure Boot key change, verify the new
state, boot with Secure Boot enabled, and rerun the enrollment helper. Do not
blindly re-enroll after an unexplained change. Do not clear the TPM to fix a
password prompt.

Test the recovery path once while present: disable Secure Boot temporarily,
boot and unlock with the recovery passphrase, then re-enable Secure Boot and
verify automatic unlocking returns. Do not re-enroll while Secure Boot is off.

**If NixOS cannot boot:** try a retained generation. To boot the unsigned
installer USB, temporarily disable Secure Boot using the supervisor password.
Open the existing encrypted root and mount it for repair:

```console
sudo cryptsetup open /dev/disk/by-partlabel/disk-main-cryptroot cryptroot
sudo mount /dev/mapper/cryptroot /mnt
sudo mount /dev/disk/by-partlabel/disk-main-ESP /mnt/boot
sudo nixos-enter --root /mnt
```

Repair or rebuild the installed system with the retained signing keys, then
restore Secure Boot. **Never rerun Disko to repair an existing installation:**
the installation command destroys the data you are trying to recover.

Keep firmware and Secure Boot revocations current, with recovery credentials
and local access available during those updates. Review older boot generations
when retiring a vulnerable kernel; signed older software remains trusted by
this policy. Nix garbage collection and boot-menu limits do not constitute
cryptographic revocation of all older signed images.

## Sources and verification boundaries

- [Lanzaboote 1.1.0 Secure Boot setup](https://github.com/nix-community/lanzaboote/blob/v1.1.0/docs/getting-started/enable-secure-boot.md)
- [The pinned stub's command-line handling](https://github.com/nix-community/lanzaboote/blob/v1.1.0/rust/uefi/stub/src/common.rs)
- [systemd TPM enrollment](https://github.com/systemd/systemd/blob/v260.2/man/systemd-cryptenroll.xml)
- [TPM PCR registry](https://uapi-group.org/specifications/specs/linux_tpm_pcr_registry/)
- [Lenovo P1/X1 Extreme manual](https://download.lenovo.com/pccbbs/mobiles_pdf/p1_x1extreme_ug_en.pdf)

`just test-disko` exercises the actual encrypted root layout and signed boot
artifacts with manual recovery in a disposable VM. `just test-thinkpad-boot`
separately exercises Secure Boot enforcement, TPM unlocking in initrd after an
OS-configuration change, rejection of changed PCR state, retained passphrase
recovery, and rejection of a modified initrd using disposable firmware and a
software TPM. These complement the physical tests above; they do not certify
Lenovo firmware behavior or the physical TPM before installation.
