#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Run this on the Mac that controls the ThinkPad." >&2
  exit 1
fi

cat <<'MESSAGE'
Leave this terminal open while using the ThinkPad desktop.
In RustDesk on this Mac, connect to: 127.0.0.1:21118
The ThinkPad must have a logged-in COSMIC session with RustDesk running.
Press Ctrl-C here to close the SSH tunnel when finished.
MESSAGE

exec ssh -N -T \
  -o ExitOnForwardFailure=yes \
  -o StrictHostKeyChecking=yes \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=3 \
  -L 127.0.0.1:21118:127.0.0.1:21118 \
  thinkpad
