{ pkgs, unstablePkgs, ... }:
{
  home.packages =
    (with pkgs; [
      arp-scan
      awscli2
      doctl
      nmap
      restic
      skopeo
    ])
    ++ (with unstablePkgs; [
      opentofu
      pulumi
      tofu-ls
    ]);
}
