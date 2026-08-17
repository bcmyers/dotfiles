#!/usr/bin/env bash

set -euo pipefail

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# The sentinel prevents command substitution from discarding trailing newlines.
selection=$(cat "$@"; printf '\034')
selection=${selection%$'\034'}

if command_exists pbcopy; then
  printf '%s' "$selection" | pbcopy
  exit 0
fi

if command_exists wl-copy; then
  printf '%s' "$selection" | wl-copy
  exit 0
fi

if [[ -n "${DISPLAY-}" ]] && command_exists xsel; then
  printf '%s' "$selection" | xsel --input --clipboard
  exit 0
fi

if [[ -n "${DISPLAY-}" ]] && command_exists xclip; then
  printf '%s' "$selection" | xclip -in -filter -selection primary | xclip -in -selection clipboard
  exit 0
fi

# Fall back to OSC 52. Its 100,000-byte sequence limit leaves room for 74,994
# bytes of input after base64 encoding and the tmux passthrough wrapper.
max_length=74994
selection_length=$(printf '%s' "$selection" | wc -c | tr -d ' ')
if ((selection_length > max_length)); then
  printf 'tmux selection is %d bytes too long; truncating\n' "$((selection_length - max_length))" >&2
fi

encoded=$(printf '%s' "$selection" | head -c "$max_length" | base64 | tr -d '\r\n')
pane_tty=$(tmux display-message -p '#{pane_tty}')
target_tty=${SSH_TTY:-$pane_tty}

if [[ -z "$target_tty" || ! -w "$target_tty" ]]; then
  printf 'cannot write OSC 52 sequence to a terminal\n' >&2
  exit 1
fi

printf '\033Ptmux;\033\033]52;c;%s\a\033\\' "$encoded" >"$target_tty"
