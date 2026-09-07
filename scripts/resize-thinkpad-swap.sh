#!/usr/bin/env bash
set -euo pipefail

die() { echo "$*" >&2; exit 1; }
(( $# == 0 )) || die "Usage: bash scripts/resize-thinkpad-swap.sh"

if [[ "$(uname -s)" == Darwin ]]; then
  [[ -t 0 && -t 1 ]] || die "Run this directly in a Mac terminal so sudo can prompt."
  exec ssh -t \
    -o StrictHostKeyChecking=yes \
    -o ConnectTimeout=15 \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    thinkpad \
    'bash -lc "cd /home/bcmyers/lib/dotfiles && exec bash scripts/resize-thinkpad-swap.sh"'
fi

[[ -e /etc/NIXOS && "$(hostname -s)" == thinkpad ]] || die "Run only on the installed ThinkPad."
if (( EUID != 0 )); then
  [[ "$(id -un)" == bcmyers ]] || die "Run as bcmyers or root."
  exec sudo bash "${BASH_SOURCE[0]}"
fi

# Only this existing regular file on the encrypted ext4 root is eligible.
swap_file=/var/lib/swapfile
target_bytes=$((64 * 1024 * 1024 * 1024))
minimum_kib=$(((target_bytes - $(getconf PAGESIZE)) / 1024))
[[ "$(readlink -f /var/lib)" == /var/lib ]] || die "Unexpected swap directory."
[[ "$(findmnt -nro FSTYPE --target /var/lib)" == ext4 ]] || die "Expected ext4."
[[ "$(readlink -f "$(findmnt -nro SOURCE --target /var/lib)")" == "$(readlink -f /dev/mapper/cryptroot)" ]] || die "Swap must remain on cryptroot."
[[ -f "$swap_file" && ! -L "$swap_file" ]] || die "Expected an existing regular swap file."
[[ "$(stat -c '%u:%a:%h' "$swap_file")" == 0:600:1 ]] || die "Swap must be owned by root, mode 600, with one hard link."

exec 9>/run/lock/thinkpad-swap-resize.lock
flock -n 9 || die "Another swap resize is running."
is_active() { awk -v file="$1" '$1 == file { found = 1 } END { exit !found }' /proc/swaps; }
has_target_size() {
  awk -v minimum="$minimum_kib" '$1 == "/var/lib/swapfile" && $2 == "file" && $3 >= minimum { found = 1 } END { exit !found }' /proc/swaps
}
if has_target_size; then
  echo "The requested 64 GiB swap file is already active."
  swapon --show
  exit 0
fi
is_active "$swap_file" || die "The original swap file must be active before resizing."

# Stop before making changes if a build or memory pressure is already present.
for process in nix nix-build rustc cargo cc1 cc1plus ld.lld; do
  if pgrep -x "$process" >/dev/null; then
    die "A Nix build or compiler is running ($process); finish it before resizing."
  fi
done
check_memory() {
  local available_kib used_kib
  available_kib=$(awk '$1 == "MemAvailable:" { print $2 }' /proc/meminfo)
  used_kib=$(awk '$1 == "/var/lib/swapfile" { print $4 }' /proc/swaps)
  (( available_kib >= used_kib + 4 * 1024 * 1024 )) || die "Not enough available RAM to safely drain the original swap file."
}
check_memory
available_bytes=$(df -B1 --output=avail /var/lib | tail -n 1)
(( available_bytes >= target_bytes + 16 * 1024 * 1024 * 1024 )) || die "Need at least 80 GiB free for the resize and temporary swap."

bridge=""
on_exit() {
  local status=$?
  trap - EXIT
  if (( status != 0 )); then
    echo "Resize stopped. No build or reboot was started." >&2
    if [[ -n "$bridge" ]]; then
      if is_active "$bridge"; then
        echo "Temporary swap remains active at $bridge; retain it until recovery is complete." >&2
      else
        rm -f -- "$bridge"
      fi
    fi
    swapon --show >&2 || true
  fi
  exit "$status"
}
trap on_exit EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

# Activate an 8 GiB temporary file before disabling the original. Failure leaves
# any active temporary swap intact. Both files stay on the encrypted root.
umask 077
bridge=$(mktemp /var/lib/.thinkpad-swap-bridge.XXXXXX)
echo "Preparing temporary swap while the existing swap file remains active."
fallocate -l 8GiB "$bridge"
mkswap "$bridge"
swapon "$bridge"
check_memory

echo "Expanding /var/lib/swapfile to 64 GiB."
swapoff "$swap_file"
fallocate -l "$target_bytes" "$swap_file"
mkswap "$swap_file"
swapon "$swap_file"
has_target_size || die "The expanded swap file did not report the expected active size."

# Only remove the temporary file after the full-size swap file is active.
swapoff "$bridge"
rm -- "$bridge"
bridge=""
echo "Verified: 64 GiB swap file is active."
swapon --show
cat <<'MESSAGE'

The Nix configuration already declares this size. Install that configuration
before the next reboot; the previous generation still declares 8 GiB.
No build, desktop activation, or reboot was started by this script.
MESSAGE
