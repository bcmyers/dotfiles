#!/usr/bin/env bash
set -euo pipefail

if [[ ! -t 0 || ! -t 1 ]]; then
  echo "Run this script directly in a terminal so sudo can prompt." >&2
  exit 1
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  exec ssh -t \
    -o StrictHostKeyChecking=yes \
    -o ConnectTimeout=15 \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    thinkpad \
    'bash -lc "cd /home/bcmyers/lib/dotfiles && exec bash scripts/upgrade-thinkpad-desktop.sh"'
fi

if [[ "$(hostname -s)" != "thinkpad" || "$(id -un)" != "bcmyers" || ! -e /etc/NIXOS ]]; then
  echo "This script requires the installed ThinkPad and user bcmyers." >&2
  exit 1
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# The active swap size excludes its header page. Require the requested 64 GiB
# file before another source build; changing the Nix declaration is not enough.
minimum_swap_kib=$((64 * 1024 * 1024 - $(getconf PAGESIZE) / 1024))
if ! awk -v minimum="$minimum_swap_kib" '
  $1 == "/var/lib/swapfile" && $2 == "file" && $3 >= minimum { found = 1 }
  END { exit !found }
' /proc/swaps; then
  echo "Stop: /var/lib/swapfile must have at least 64 GiB active before building." >&2
  echo "Expand and activate the swap file first; this script has not started a build." >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Commit and review the checkout before building the desktop upgrade." >&2
  exit 1
fi
revision="$(git rev-parse HEAD)"
flake="git+file://$(pwd)?rev=$revision"
build_roots="${XDG_STATE_HOME:-$HOME/.local/state}/thinkpad-install/builds/$revision"
mkdir -p "$build_roots"

echo "Building reviewed ThinkPad revision $revision."
# Keep distinct GC roots outside the checkout. Root the system before running
# the VM test, so a test failure cannot discard a successful system build.
./scripts/nix-flake.sh build \
  "$flake#nixosConfigurations.thinkpad.config.system.build.toplevel" \
  --out-link "$build_roots/system" --cores 3 --max-jobs 2

echo "Testing COSMIC's remote-desktop portal."
./scripts/nix-flake.sh build \
  "$flake#checks.x86_64-linux.cosmic-remote-desktop" \
  --out-link "$build_roots/portal-test" --cores 3 --max-jobs 2

echo "Installing the new configuration for the next boot."
echo "Enter your ThinkPad login password when sudo asks."
sudo nix --extra-experimental-features 'nix-command flakes' \
  run "$flake#nixos-rebuild" -- boot --flake "$flake#thinkpad"

sudo sbctl status
echo "The bootloaders and unified images under /boot/EFI/Linux/ must be signed."
echo "The detached kernel under /boot/EFI/nixos/ can appear unsigned."
sudo sbctl verify

cat <<'MESSAGE'

The next boot configuration is installed. Your current desktop is still running.
Save your work, then reboot the ThinkPad and log into COSMIC locally.
After login, check the dock and test the private RustDesk connection.
MESSAGE
