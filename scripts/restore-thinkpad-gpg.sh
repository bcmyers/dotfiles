#!/usr/bin/env bash
# Run from an interactive Mac terminal after verifying the ThinkPad host key.
# Set THINKPAD_HOST to the current Tailscale IP during bootstrap if needed.
# Contains only the public key fingerprint; secret subkeys are streamed to tmpfs.
set -euo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
  printf 'Run this restore helper on the Mac.\n' >&2
  exit 1
fi

fingerprint=39EE837B09384924CB2A8B96A65C0C4DE57884B8
destination="bcmyers@${THINKPAD_HOST:-thinkpad.bilby-allosaurus.ts.net}"
ssh_options=(
  -F /dev/null
  -o IdentitiesOnly=yes
  -o IdentityAgent=none
  -o HostKeyAlias=thinkpad.bilby-allosaurus.ts.net
  -o StrictHostKeyChecking=yes
  -o UpdateHostKeys=no
  -o BatchMode=yes
  -o ConnectTimeout=15
  -i "$HOME/.ssh/id_ed25519"
)

if [[ ! -t 0 || ! -t 1 ]]; then
  printf 'Run this script directly in your Mac terminal, without piping it.\n' >&2
  exit 1
fi

remote_bash() {
  local script=$1
  shift
  # Quote for the remote login shell, which may be Fish rather than Bash.
  script=${script//\'/\'\\\'\'}
  command ssh "${ssh_options[@]}" "$@" "$destination" "bash -lc '$script'"
}

export GPG_TTY
GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null
gpg --list-secret-keys "$fingerprint" >/dev/null

stage_dir=$(remote_bash '
set -euo pipefail
umask 077
runtime=/run/user/$(id -u)
test "$(findmnt -n -o FSTYPE --target "$runtime")" = tmpfs
mktemp -d "$runtime/thinkpad-gpg-restore.XXXXXXXX"
')

if [[ ! "$stage_dir" =~ ^/run/user/[0-9]+/thinkpad-gpg-restore\.[A-Za-z0-9]+$ ]]; then
  printf 'Unexpected staging directory; stopping before export.\n' >&2
  exit 1
fi

cleanup() {
  local original_status=$?
  if ! remote_bash "if test -d '$stage_dir'; then rm -f -- '$stage_dir/subkeys.asc' && rmdir -- '$stage_dir'; fi" </dev/null >/dev/null; then
    printf 'Could not clean up ThinkPad temporary directory: %s\n' "$stage_dir" >&2
  fi
  return "$original_status"
}
trap cleanup EXIT

printf 'Exporting secret subkeys from the Mac. Enter the GPG passphrase if prompted.\n'
# The primary secret key is excluded. No key export is saved on the Mac.
gpg --export-secret-subkeys --armor "$fingerprint" |
  remote_bash "umask 077; cat > '$stage_dir/subkeys.asc'"

printf '\nImporting on the ThinkPad through an interactive SSH terminal.\n'
printf 'Enter your GPG passphrase in its prompt; it may ask for each subkey.\n'
remote_bash "
set -euo pipefail
export GPG_TTY=\$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null
gpg --import '$stage_dir/subkeys.asc'
rm -f -- '$stage_dir/subkeys.asc'
rmdir -- '$stage_dir'
gpg --list-secret-keys --with-subkey-fingerprint '$fingerprint'
" -t

printf '\nImport finished. A sec# primary-key stub is expected.\n'
printf 'Check for encryption subkey 82081CF07E9C1664 and signing subkey B86678B99457460F.\n'
