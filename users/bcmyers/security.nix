{
  lib,
  pkgs,
  unstablePkgs,
  ...
}:
{
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 7200;
    defaultCacheTtlSsh = 7200;
    enableBashIntegration = true;
    enableFishIntegration = true;
    # Keep the Mac's existing SSH identities during migration. On the
    # ThinkPad, OpenSSH owns SSH and GPG handles Pass and Git signing only.
    enableSshSupport = pkgs.stdenv.hostPlatform.isDarwin;
    maxCacheTtl = 7200;
    maxCacheTtlSsh = 7200;
    pinentry.package =
      if pkgs.stdenv.hostPlatform.isDarwin then unstablePkgs.pinentry_mac else pkgs.pinentry-curses;
    # Transitional Mac-only inventory. Retire these SSH authorizations only
    # after its Ed25519 device key has been tested against every destination.
    sshKeys = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [
      # Primary key A65C0C4DE57884B8.
      "1CA52012CCEA51647915567430D8C22585EDAFDD"
      # Encryption subkey 82081CF07E9C1664.
      "BC2C3DB08614B3D98C10B2E4451EFA2458CA01E3"
      # Signing subkey B86678B99457460F.
      "B4DE81FCAF8B3C277C3D565848BFAE92649C2B40"
      # Authentication subkey 9CB4683AD4C5EC7B.
      "1639EE9892C9132E0EC67689AD31751E651F05DE"
    ];
  };
}
