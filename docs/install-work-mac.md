# Install Home Manager on the work Mac

This target manages only `/Users/brian.myers`. It does not use nix-darwin,
modify `/etc`, change macOS defaults, or take ownership of corporate-managed
services. It also leaves the existing Nix installation, registry, settings,
and garbage collection under system or company management. Nix and Homebrew
must already be installed before starting.

## 1. Clone and build

```console
mkdir -p ~/lib
git clone https://github.com/bcmyers/dotfiles.git ~/lib/dotfiles
cd ~/lib/dotfiles
git switch master
just build-work-mac
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
and `ls` Fish abbreviations, an unsigned test commit, the existing SSH agent,
Neovim, tmux, Alacritty, and any work-specific tools.

The work profile deliberately does not select a Git signing key, start a GPG
SSH agent, replace `SSH_AUTH_SOCK`, or manage `~/.aws/config`. Add work-specific
signing, SSH-agent, or AWS policy under `users/brian.myers` only after choosing
the company-approved identities and authentication mechanisms. The shared GPG,
Password Store, and AWS command-line tools do not provide access to personal
keys, password entries, or accounts by themselves.

The work profile intentionally does not define the personal Anthropic or
Twilio environment variables or load the personal Windsurf editor integration.
Do not copy the personal age identity, GPG private keys, Password Store data,
or `secrets/personal.yaml` access to the work machine.

## One-time Fish migration, if needed

The managed Fish configuration never deletes universal or global
`fish_user_paths`. If old personal configuration was copied onto this machine,
inspect it first with `set --show fish_user_paths`. Remove entries only after
confirming they are obsolete; corporate installers may intentionally store
paths there.

## 6. Recover or roll back

Standalone Home Manager activation is not transactional after preflight. If it
fails after linking files, fix the reported phase and rerun the same reviewed
checkout before opening a new shell.

List retained generations and activate the chosen previous one directly:

```console
home-manager generations
previous_generation='/nix/store/...-home-manager-generation'
"$previous_generation/activate"
```

The generation path comes from the first command. A `.home-manager-backup` file
is the pre-activation file, not a complete generation rollback; restore one
only after confirming the current generation no longer owns its destination.
