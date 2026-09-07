#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" == "Darwin" ]]; then
  exec ssh -T -o StrictHostKeyChecking=yes -o ConnectTimeout=15 thinkpad \
    'bash -lc "cd /home/bcmyers/lib/dotfiles && exec bash scripts/prepare-thinkpad-vnc.sh"'
fi

if [[ "$(hostname -s)" != "thinkpad" || "$(id -un)" != "bcmyers" || ! -e /etc/NIXOS ]]; then
  echo "Run this from the Mac or the installed ThinkPad as bcmyers." >&2
  exit 1
fi

cd "$(dirname "${BASH_SOURCE[0]}")/.."
umask 077
trial_root="${XDG_STATE_HOME:-$HOME/.local/state}/thinkpad-install/desktop-trials"
config_root="$trial_root/krfb-config"
mkdir -p "$config_root"
./scripts/nix-flake.sh build .#thinkpad-vnc-trial --out-link "$trial_root/krfb"

# Keep the trial separate from any existing KDE configuration and credentials.
# Krfb generates its own sharing password when it starts; never put one in Nix.
if [[ ! -e "$config_root/krfbrc" ]]; then
  cat > "$config_root/krfbrc" <<'CONFIG'
[TCP]
useDefaultPort=true
publishService=false

[Security]
noWallet=true
allowDesktopControl=true
allowUnattendedAccess=true

[FrameBuffer]
preferredFrameBufferPlugin=pw
CONFIG
fi

# Upgrade an existing trial profile too, preserving its generated passwords.
python3 - "$config_root/krfbrc" <<'PYCONFIG'
import configparser
import os
from pathlib import Path
import sys
import tempfile

path = Path(sys.argv[1])
config = configparser.RawConfigParser()
config.optionxform = str
config.read(path)
if not config.has_section("Security"):
    config.add_section("Security")
config.set("Security", "allowUnattendedAccess", "true")
with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as output:
    config.write(output, space_around_delimiters=False)
    temporary = output.name
os.replace(temporary, path)
PYCONFIG

QT_QPA_PLATFORM=offscreen "$trial_root/krfb/bin/krfb" --version
cat <<'MESSAGE'
Krfb is prepared for an unattended-access trial; it has not been started.
The existing firewall must keep TCP 5900 closed on network interfaces.
Krfb listens on all interfaces; use the SSH tunnel, not a firewall opening.
The private trial profile uses password-authenticated unattended access.
Krfb stores its generated password in this private profile, without KWallet.
When present at the ThinkPad, launch the following command in COSMIC:
MESSAGE
printf 'XDG_CONFIG_HOME=%q QT_QPA_PLATFORM=wayland %q\n' \
  "$config_root" "$trial_root/krfb/bin/krfb"
echo "For the first setup, select the monitor in COSMIC and choose Always Allow."
echo "Set/save Krfb's UNATTENDED access password on your Mac; it differs from the invitation password."
echo "On the Mac: just connect-thinkpad-vnc, then Screen Sharing at vnc://127.0.0.1:15900."
