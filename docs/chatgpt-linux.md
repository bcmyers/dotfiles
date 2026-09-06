# ChatGPT Linux preview and automatic updates

The ThinkPad installs the official OpenAI desktop app. OpenAI publishes a
[Linux preview](https://learn.chatgpt.com/docs/linux/linux-app) for Ubuntu,
Debian, and Fedora. NixOS needs the packaging adapter in `pkgs/chatgpt`;
it is not one of the distributions listed as officially supported.

The adapter uses the original versioned `.deb`, checks its SHA256, adjusts
Linux library paths, and supplies a launcher and desktop entry. It does not
run Debian's installation scripts or add an APT repository to NixOS. COSMIC
uses the app's GTK integration and its default XWayland behavior.

## Follow the newest public Linux build

The requested update policy is implemented in `modules/home/apps/chatgpt.nix`:

1. `chatgpt-update.timer` checks hourly, with up to five minutes of jitter.
   Missed checks are caught up when the user service manager starts.
2. The updater verifies OpenAI's signed `InRelease` metadata with the public
   key in `files/chatgpt/repository.asc`, then verifies the package index's
   size and SHA256. It only accepts the expected x64 ChatGPT download path.
3. If a newer release is available, Nix downloads and verifies that package
   and applies the same library adapter. The adapter and its dependencies
   remain pinned by the system configuration.
4. After the build succeeds, the updater atomically switches the private
   profile at `~/.local/state/chatgpt/profile`. It keeps three generations,
   including a fallback for the first update. A failed download, signature
   check, or build leaves the current app selected.
5. Quit and reopen ChatGPT to use an update. The updater does not restart an
   active window.

This tracks the newest public package in OpenAI's Linux `stable` APT suite,
which currently distributes the Linux preview. It does not use unofficial
nightly builds. No root password, full NixOS rebuild, or Git commit is needed
for an app update. Other system packages keep their normal flake pins.

The repository also pins an initial app version so a fresh installation
works before the first update check. Routine rebuilds preserve a newer app
already selected by the private profile.

## Check, update, or roll back

After activating the configuration:

```sh
chatgpt-update --check
systemctl --user list-timers chatgpt-update.timer
journalctl --user -u chatgpt-update.service -n 30
```

To check and install immediately, run `chatgpt-update`.

After at least one automatic update, quit ChatGPT and roll back with:

```sh
systemctl --user stop chatgpt-update.timer
nix-env --profile "$HOME/.local/state/chatgpt/profile" --rollback
```

Reopen ChatGPT. The timer stays stopped until restarted or the user service
manager starts again; restart it when ready with
`systemctl --user start chatgpt-update.timer`.

If a future app changes its dependencies, download layout, or signing key,
the updater stops with an error in its journal. Update the adapter or review
the new official signing key, then retry. The tests for tampered metadata
and preserving an installed app after build failure are available through
`just test-chatgpt-updater`.

## Repository signing key

The public key was extracted from OpenAI's official
`chatgpt_26.901.51231_amd64.deb` package's `postinst` script. Its fingerprint is:

```text
3BFA 0E4A E8B8 CC16 A2D9 BA68 4A3B 4A56 6C46 60E4
```

It successfully verified OpenAI's signed repository metadata during setup.
This file contains no private key or account credential.

## Setup verification

On September 6, 2026, the Nix package built successfully and opened a window
on an isolated X11 display. Its bundled Codex and Node runtimes also ran.
The updater passed its metadata and build-failure tests, verified live signed
metadata, and installed and rolled back a release in a temporary Nix profile.
Account sign-in and normal use in the physical COSMIC session remain to be
checked after activation.
