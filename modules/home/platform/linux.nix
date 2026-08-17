{
  config,
  lib,
  unstablePkgs,
  ...
}:
lib.mkIf unstablePkgs.stdenv.hostPlatform.isLinux {
  home.packages = [ unstablePkgs.wl-clipboard ];

  sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
}
