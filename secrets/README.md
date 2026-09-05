# Encrypted secrets

`personal.yaml` contains the API credentials used by `bcmyers` on the personal
Mac and ThinkPad. It is encrypted to separate personal-Mac and ThinkPad age
recipients declared in `../.sops.yaml`; only the public recipients and
encrypted document belong in Git.

The `brian.myers@work-mac` profile deliberately does not import this file. If
the work machine eventually needs managed secrets, create a separate encrypted
document with its own recipient rather than adding the work recipient to
`personal.yaml`.

Home Manager reads the machine identities from:

```text
macOS: ~/Library/Application Support/sops/age/keys.txt
Linux: ~/.config/sops/age/keys.txt
```

Credentials are decrypted into the user's SOPS runtime files. They are not
exported by shell startup. Use these wrappers from any shell:

```console
with-anthropic COMMAND ARGUMENTS
with-twilio COMMAND ARGUMENTS
```

`with-anthropic` supplies only `ANTHROPIC_API_KEY`; `with-twilio` supplies
`TWILIO_SID` and `TWILIO_CLIENT_SECRET`. They fail before starting the command
when a required secret is missing or empty. `with-anthropic true` and
`with-twilio true` check availability without printing values. Log out and back
in after migrating from the old shell configuration to discard inherited
credentials in existing processes.

This limits accidental environment inheritance. Programs running as `bcmyers`
can still read that user's decrypted files; the wrappers are not an access
control boundary. Codex runs as `bcmyers` with its normal sandbox.

Edit the encrypted file from the repository root with:

```sh
./scripts/nix-flake.sh run .#sops -- secrets/personal.yaml
```

The dedicated ThinkPad identity is staged on the Mac at
`~/Library/Application Support/sops/age/thinkpad-keys.txt` until NixOS is
installed. Copy it to the Linux path over an authenticated SSH connection as
described in `../docs/install-thinkpad.md`. Keep both identity files mode 600
and their containing directories mode 700.

To add or replace a machine identity, generate it through the pinned flake app,
add only its public recipient to `.sops.yaml`, and update the recipients:

```sh
./scripts/nix-flake.sh run .#age-keygen -- -o /secure/path/to/keys.txt
./scripts/nix-flake.sh run .#sops -- updatekeys --yes secrets/personal.yaml
```

Only encrypted SOPS documents belong in this directory. Never commit an age
private key, a decrypted secret file, or secret values in shell configuration.
