# Simulate failure paths without allocating files or touching live swap.
from pathlib import Path
import subprocess

repo = Path(__file__).resolve().parents[1]
source = (repo / 'scripts/resize-thinkpad-swap.sh').read_text()
phase = source[source.index('bridge=""\n'):]
phase = phase.replace('  exit "$status"\n', '  printf "STATE main=%s bridge=%s removed=%s\\n" "$main_active" "$bridge_active" "$removed"\n  exit "$status"\n')
mocks = r'''
set -euo pipefail
swap_file=/var/lib/swapfile
target_bytes=68719476736
main_active=1
main_size=8
bridge_active=0
removed=0
die() { echo "$*" >&2; exit 1; }
check_memory() { return 0; }
is_active() { [[ "$1" == /test-bridge && "$bridge_active" == 1 ]]; }
has_target_size() { [[ "$main_active" == 1 && "$main_size" == 64 ]]; }
mktemp() { echo /test-bridge; }
fallocate() {
  if [[ "$3" == "$swap_file" ]]; then
    [[ "$main_active" == 0 && "$bridge_active" == 1 ]] || die 'Unsafe main resize ordering'
    [[ "$FAIL_AT" != main_allocate ]] || return 17
    main_size=64
  else
    [[ "$main_active" == 1 ]] || die 'Original swap unavailable during bridge creation'
  fi
}
mkswap() {
  if [[ "$1" == "$swap_file" ]]; then
    [[ "$main_active" == 0 && "$bridge_active" == 1 ]] || die 'Unsafe mkswap ordering'
  fi
}
swapon() {
  case "$1" in
    --show) return 0;;
    /test-bridge)
      [[ "$FAIL_AT" != bridge_on ]] || return 17
      bridge_active=1;;
    "$swap_file")
      [[ "$FAIL_AT" != main_on ]] || return 17
      main_active=1;;
    *) die 'Unexpected swap target';;
  esac
}
swapoff() {
  if [[ "$1" == "$swap_file" ]]; then
    [[ "$bridge_active" == 1 ]] || die 'Original disabled without bridge'
    [[ "$FAIL_AT" != main_off ]] || return 17
    main_active=0
  else
    [[ "$main_active" == 1 && "$main_size" == 64 ]] || die 'Bridge disabled before main ready'
    [[ "$FAIL_AT" != bridge_off ]] || return 17
    bridge_active=0
  fi
}
rm() {
  [[ "${!#}" == /test-bridge && "$bridge_active" == 0 ]] || die 'Active or unexpected file removal'
  removed=1
}
'''
for failure, rc, expected in [
    ('none', 0, 'STATE main=1 bridge=0 removed=1'),
    ('bridge_on', 17, 'STATE main=1 bridge=0 removed=1'),
    ('main_off', 17, 'STATE main=1 bridge=1 removed=0'),
    ('main_allocate', 17, 'STATE main=0 bridge=1 removed=0'),
    ('main_on', 17, 'STATE main=0 bridge=1 removed=0'),
    ('bridge_off', 17, 'STATE main=1 bridge=1 removed=0'),
]:
    r = subprocess.run(['bash', '-c', 'FAIL_AT=' + failure + '\n' + mocks + phase], text=True, capture_output=True)
    assert r.returncode == rc and expected in r.stdout, (failure, r.returncode, r.stdout, r.stderr)
    print(f'PASS: {failure}: {expected}')

source = (repo / 'scripts/upgrade-thinkpad-desktop.sh').read_text()
start = source.index('if ! awk -v minimum=')
end = source.index('\nif [[ -n', start)
guard = source[start:end].replace('/proc/swaps', '/dev/stdin')
for gib, expected in [(8, 1), (32, 1), (64, 0)]:
    r = subprocess.run(['bash', '-c', 'minimum_swap_kib=$((64 * 1024 * 1024 - 4))\n' + guard], input=f'Filename Type Size Used Priority\n/var/lib/swapfile file {gib * 1024 * 1024 - 4} 0 -2\n', text=True, capture_output=True)
    assert r.returncode == expected, (gib, r)
print('PASS: build guard rejects 8/32 GiB and accepts 64 GiB')
