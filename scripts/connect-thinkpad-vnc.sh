#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Run this on the Mac that controls the ThinkPad." >&2
  exit 1
fi

cat <<'MESSAGE'
Leave this terminal open while using the ThinkPad desktop.
In the Mac's Screen Sharing app, connect to: vnc://127.0.0.1:15900
Use the password displayed by Krfb on the ThinkPad and approve the connection.
The ThinkPad must have a logged-in COSMIC session with Krfb running.
Press Ctrl-C here to close the SSH tunnel when finished; also quit Krfb.
MESSAGE

exec ssh -N -T \
  -o ExitOnForwardFailure=yes \
  -o StrictHostKeyChecking=yes \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=3 \
  -L 127.0.0.1:15900:127.0.0.1:5900 \
  thinkpad
