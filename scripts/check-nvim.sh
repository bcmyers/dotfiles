#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Check the installed Home Manager configuration, including startup errors.
# First use may download the configured plugins and syntax parsers.
exec nvim --headless \
  --cmd 'lua _G.startup_errors = {}; local original = vim.notify; vim.notify = function(message, level, options) if level and level >= vim.log.levels.ERROR then table.insert(_G.startup_errors, tostring(message)) end return original(message, level, options) end' \
  -c 'luafile tests/nvim-smoke.lua'
