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

echo "Building the ThinkPad and testing COSMIC's remote-desktop portal."
./scripts/nix-flake.sh build \
  .#nixosConfigurations.thinkpad.config.system.build.toplevel \
  .#checks.x86_64-linux.cosmic-remote-desktop \
  --no-link --cores 2 --max-jobs 1

echo "Installing the new configuration for the next boot."
echo "Enter your ThinkPad login password when sudo asks."
sudo nix --extra-experimental-features 'nix-command flakes' \
  run .#nixos-rebuild -- boot --flake .#thinkpad

sudo sbctl status
echo "The bootloaders and unified images under /boot/EFI/Linux/ must be signed."
echo "The detached kernel under /boot/EFI/nixos/ can appear unsigned."
sudo sbctl verify

cat <<'MESSAGE'

The next boot configuration is installed. Your current desktop is still running.
Save your work, then reboot the ThinkPad and log into COSMIC locally.
After login, check the dock and test the private RustDesk connection.
MESSAGE
