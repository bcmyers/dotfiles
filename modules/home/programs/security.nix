{
  pkgs,
  unstablePkgs,
  ...
}:
{
  programs = {
    gpg = {
      enable = true;
      package = unstablePkgs.gnupg;
      settings = {
        display-charset = "utf-8";
        keyid-format = "long";
        no-comments = true;
        no-emit-version = true;
        no-greeting = true;
        trust-model = "tofu+pgp";
        utf8-strings = true;
        with-fingerprint = true;
        with-keygrip = true;
      };
    };

    password-store = {
      enable = true;
      package = unstablePkgs.pass.withExtensions (extensions: [ extensions.pass-otp ]);
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 7200;
    defaultCacheTtlSsh = 7200;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableSshSupport = true;
    maxCacheTtl = 7200;
    maxCacheTtlSsh = 7200;
    pinentry.package =
      if pkgs.stdenv.hostPlatform.isDarwin then unstablePkgs.pinentry_mac else pkgs.pinentry-curses;
    # Migrated GPG-agent SSH keygrips. The ThinkPad runbook requires comparing
    # this inventory with restored secret keys and pruning obsolete entries.
    sshKeys = [
      "1CA52012CCEA51647915567430D8C22585EDAFDD"
      "BC2C3DB08614B3D98C10B2E4451EFA2458CA01E3"
      "B4DE81FCAF8B3C277C3D565848BFAE92649C2B40"
      "1639EE9892C9132E0EC67689AD31751E651F05DE"
      "51849D83C9C8E33DFC38088C7BE093B64E31D1CC"
      "E4F18E3190F03FD1DE4FD0DD0D014CF062A3850D"
    ];
  };
}
