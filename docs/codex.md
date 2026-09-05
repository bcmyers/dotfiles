# Codex on the ThinkPad

`hosts/thinkpad/codex.nix` installs the Codex CLI from the pinned
`nixpkgs-unstable` input. It is a system package, so it is available before
Home Manager can decrypt the personal SOPS settings.

Codex runs as the normal `bcmyers` user, with its built-in sandbox. There is
no dedicated Codex VM or user. NixOS also installs `bubblewrap` so the Linux
sandbox helper is available from the first login.

This module installs the CLI. The pinned Nixpkgs `chatgpt` desktop package is
macOS-only; it does not provide the Linux desktop app on NixOS. The existing
Pop!_OS `.deb` installation does not carry over to NixOS. Desktop packaging
and browser integration need a separate NixOS compatibility check before
promising the same graphical workflow. The CLI can use ChatGPT sign-in.

## First use

After installing NixOS, open a terminal and run:

```console
codex --version
codex login
codex login status
```

Complete the ChatGPT sign-in in your browser. For an SSH-only session, use
`codex login --device-auth` and follow the displayed instructions instead.
Account sign-in and plugin connections are local state; credentials and
`auth.json` must not be committed or copied into the Nix store.

## Configuration

Nix generates `/etc/codex/config.toml` with the existing personal defaults:

```toml
model = "gpt-6-astra"
model_reasoning_effort = "xhigh"
check_for_update_on_startup = false
```

The model still needs to be available to the signed-in account. Choose another
model with `/model` or `codex --model MODEL` when needed.

Codex can write normal user preferences, trusted-project entries, and MCP
configuration to `~/.codex/config.toml`. That file overrides the Nix-managed
system defaults and is deliberately not a read-only Home Manager symlink.
Project configuration and command-line flags can also override defaults.
Authentication, session history, and installed plugins remain under Codex's
normal local storage. The module does not change its permissions or sandbox
defaults. Personal API credentials are available through explicit
`with-anthropic` and `with-twilio` commands rather than inherited by every
shell. These are convenience controls, not isolation from the `bcmyers` account.

Edit the Nix module to change the defaults on subsequent rebuilds. Do not put
API keys, access tokens, or MCP secrets in that module: generated Nix store
files are readable by other local users.

## Updates

Codex follows `flake.lock`, just like the other selected development tools.
It is not updated by npm or the standalone installer, and its startup update
check is disabled because Nix owns the installed executable.

For an already reviewed repository update:

```console
git pull --ff-only
just check
just build-thinkpad
just switch-thinkpad
codex --version
```

When preparing a new dependency update, update `nixpkgs-unstable` on a review
branch, then check and build before committing the lock file:

```console
./scripts/nix-flake.sh flake update nixpkgs-unstable
just check
just build-thinkpad
```

This also updates the other tools using that input. It does not guarantee
the same-day upstream Codex release; the installed version is the one in the
reviewed Nixpkgs revision.

## References

- [Codex CLI](https://learn.chatgpt.com/docs/codex/cli)
- [Configuration precedence](https://learn.chatgpt.com/docs/config-file/config-basic)
- [Authentication](https://learn.chatgpt.com/docs/auth)
- [Linux desktop availability](https://learn.chatgpt.com/docs/linux/linux-app)
