# Neovim package updates

Neovim's native package manager reads exact plugin commits from `init.lua` and
the resolved revisions from `nvim-pack-lock.json`. Home Manager installs the
lock file read-only, so do not try to update it in the active `~/.config/nvim`
symlink.

To update plugins, copy this directory to a writable temporary config, run
Neovim there, execute `:lua vim.pack.update()`, review the selected updates,
and copy the resulting lock file and exact commit values back into this
directory. Before committing, verify that every lock-file `rev` matches its
quoted `version`; otherwise Neovim continues using the older locked revision.
