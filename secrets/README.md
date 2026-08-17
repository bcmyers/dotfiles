# Encrypted secrets

`mac.yaml` is encrypted with SOPS and the age recipient declared in
`../.sops.yaml`. The corresponding private key belongs at:

```text
~/Library/Application Support/sops/age/keys.txt
```

Edit the encrypted file from the repository root with:

```sh
sops secrets/mac.yaml
```

Only encrypted SOPS documents belong in this directory. Never commit an age
private key or a decrypted secret file.
