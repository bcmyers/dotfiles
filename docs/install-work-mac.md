# Install Home Manager on the work Mac

This target manages only `/Users/brian.myers`. It does not use nix-darwin,
modify `/etc`, change macOS defaults, or take ownership of corporate-managed
services. Nix and Homebrew must already be installed before starting.

## 1. Clone and build

```console
mkdir -p ~/lib
git clone https://github.com/bcmyers/dotfiles.git ~/lib/dotfiles
cd ~/lib/dotfiles
git switch master
just build-home-work-mac
```

Review the build before activating it. The target is
`homeConfigurations."brian.myers@work-mac"` and uses `/Users/brian.myers`.
While the work is still in a pull request, switch to its exact reviewed branch
or commit instead of `master`.

## 2. Activate Home Manager

```console
just switch-work-mac
```

The recipe gives conflicting pre-existing files the
`.home-manager-backup` suffix. Inspect those files before deleting them. If a
backup with that name already exists, move or review it before retrying.

Home Manager may ask for permission to update applications. Grant the terminal
emulator running the activation access under **System Settings → Privacy &
Security → App Management**.

## 3. Keep the system login shell under macOS management

Standalone Home Manager installs and configures Nix Fish but cannot add it to
`/etc/shells` or change the existing macOS account record. Keep the existing
Homebrew Fish login shell unless the company-approved system configuration is
changed separately. Once the shell starts, Home Manager puts Nix executables
ahead of Homebrew and loads the managed Fish configuration.

Do not uninstall the Homebrew Fish bootstrap on this machine merely because
Nix supplies a newer Fish executable in the user profile.

## 4. Verify

Open a new terminal and run:

```console
echo $SHELL
type -a fish fzf pass prompt nvim
git config --global user.email
```

The Git email should be `brianmyers@openai.com`. Also verify the `c`, `cc`,
and `ls` Fish abbreviations, a GPG-signed test commit, GPG-agent SSH access,
Neovim, tmux, Alacritty, and any work-specific tools.

The work profile intentionally does not define the personal Anthropic or
Twilio environment variables. Do not copy the personal age identity or
`secrets/personal.yaml` access to the work machine.
