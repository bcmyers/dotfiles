{ unstablePkgs, ... }:
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

}
