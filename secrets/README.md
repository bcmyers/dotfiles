# Encrypted secrets

`shared.yaml` contains the API credentials used by Fish on both macOS and
Linux. It is encrypted to separate Mac and ThinkPad age recipients declared in
`../.sops.yaml`; only the public recipients and encrypted document belong in
Git.

Home Manager reads the machine identities from:

```text
macOS: ~/Library/Application Support/sops/age/keys.txt
Linux: ~/.config/sops/age/keys.txt
```

Edit the encrypted file from the repository root with:

```sh
./nix-flake.sh run .#sops -- secrets/shared.yaml
```

The dedicated ThinkPad identity is staged on the Mac at
`~/Library/Application Support/sops/age/thinkpad-keys.txt` until NixOS is
installed. Copy it to the Linux path over an authenticated SSH connection as
described in `../docs/install-thinkpad.md`. Keep both identity files mode 600
and their containing directories mode 700.

To add or replace a machine identity, generate it through the pinned flake app,
add only its public recipient to `.sops.yaml`, and update the recipients:

```sh
./nix-flake.sh run .#age-keygen -- -o /secure/path/to/keys.txt
./nix-flake.sh run .#sops -- updatekeys --yes secrets/shared.yaml
```

Only encrypted SOPS documents belong in this directory. Never commit an age
private key, a decrypted secret file, or secret values in shell configuration.
