#!/usr/bin/env bash
set -euo pipefail

# Run interactively on the installed ThinkPad, after booting with Secure Boot.
# No passphrase is passed in an argument, environment variable, or log.
die() { echo "$*" >&2; exit 1; }
if (( $# != 0 || EUID != 0 )); then
  echo 'Usage: sudo ./scripts/enroll-thinkpad-tpm.sh' >&2
  exit 2
fi
if [[ ! -e /etc/NIXOS || "$(hostname)" != thinkpad ]]; then
  echo 'Run this only on the installed ThinkPad NixOS system.' >&2
  exit 1
fi

disk=/dev/disk/by-id/nvme-WDC_PC_SN720_SDAQNTW-512G-1001_184521422453
device=/dev/disk/by-partlabel/disk-main-cryptroot
[[ "$(lsblk -dnro SERIAL "$disk")" == 184521422453 ]] || die 'Internal SSD serial does not match.'
[[ "$(lsblk -nro PKNAME "$device")" == "$(basename "$(readlink -f "$disk")")" ]] || die 'LUKS partition is on the wrong disk.'
[[ "$(readlink -f "$(findmnt -nro SOURCE /)")" == "$(readlink -f /dev/mapper/cryptroot)" ]] || die 'The current root is not cryptroot.'
mapped_device=$(cryptsetup status cryptroot | awk '$1 == "device:" { print $2 }')
[[ "$(readlink -f "$device")" == "$(readlink -f "$mapped_device")" ]] || die 'cryptroot is backed by a different partition.'
cryptsetup isLuks --type luks2 "$device"

systemd-analyze condition ConditionSecurity=uefi-secureboot
systemd-analyze condition ConditionSecurity=measured-uki
# StubInfo is UTF-16LE; the expected Lanzaboote identifier is ASCII.
stub_info=$(tail -c +5 /sys/firmware/efi/efivars/StubInfo-4a67b082-0a4c-41cf-b6c7-440b29bb8c4f | tr -d '\000')
[[ "$stub_info" == lanzastub\ * ]] || die 'The running system was not booted by Lanzaboote.'
[[ "$(od -An -tu1 -j4 -N1 /sys/firmware/efi/efivars/SetupMode-8be4df61-93ca-11d2-aa0d-00e098032b8c | tr -d ' ')" == 0 ]] || die 'Firmware is still in Setup Mode.'

echo 'First, enter your recovery passphrase to prove it works without the TPM.'
cryptsetup open --type luks2 --test-passphrase --disable-external-tokens "$device"

# PCR 0 binds firmware; PCR 7 binds Secure Boot policy and signing authority.
# Routine OS generations use the same signing authority. Firmware/key changes
# may require recovery. Explicit PCRs avoid changes to systemd defaults.
# A fresh TPM slot is enrolled before old TPM slots are removed; passwords stay.
systemd-cryptenroll \
  --tpm2-device=auto \
  --tpm2-pcrs=0:sha256+7:sha256 \
  --tpm2-with-pin=no \
  --wipe-slot=tpm2 \
  "$device"

echo 'TPM enrollment completed; recovery passphrase retained.'
echo 'Reboot while present, then test SSH from the Mac without a local login.'
