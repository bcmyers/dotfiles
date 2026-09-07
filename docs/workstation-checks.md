# Workstation checks after rebuilding

Nix and Home Manager install the editor, terminal configuration, and ThinkPad
keyboard mapping. Apply the host configuration before these checks. A build
alone does not update the running system or user configuration.

## Caps Lock and tmux

The ThinkPad maps Caps Lock to Control with `services.keyd`. This applies to
physical keyboards in COSMIC, the login screen, and Linux consoles. Firmware
and the early disk recovery prompt are outside this mapping.

After activating or rebooting, check `systemctl is-active keyd`, then test
Caps Lock+A in a terminal. The tmux prefix is **Ctrl+A**, so Caps Lock+A should
work as the prefix too. Follow it with `c` to create a tmux window.

Home Manager already owns tmux: the prefix is Ctrl+A, mouse support is on,
and the terminal type is `tmux-256color`. In a new tmux session, inspect them:

```sh
tmux show-option -g prefix
tmux show-option -g mouse
tmux show-option -g default-terminal
```

An existing tmux server may retain its previous configuration; finish its
sessions or reload the installed configuration when convenient.

## Neovim

After applying Home Manager, run this from the repository:

```sh
just test-nvim
```

This starts the installed Neovim configuration without opening a window,
checks for startup errors, waits for all configured syntax parsers, parses a
Lua buffer, and checks that completion uses its portable Lua matcher. The
first run requires internet access to download plugins and parsers.

Plugin commits are pinned in `files/nvim/init.lua` and the tracked lockfile.
On startup, cached checkouts are moved to changed explicit pins before their
code loads. Home Manager seeds a writable lockfile because Neovim's package
manager updates it during that synchronization. Keep both tracked files in
sync when deliberately upgrading plugins.

The pinned Tree-sitter plugin uses `require("nvim-treesitter").install`;
the removed `ensure_installed` function caused the initial startup error.
Blink uses its Lua matcher so a fresh install does not depend on downloading
or compiling a separate native fuzzy-matching library.
