{
  lib,
  unstablePkgs,
  ...
}:
lib.mkIf unstablePkgs.stdenv.hostPlatform.isLinux {
  home.packages = [ unstablePkgs.wl-clipboard ];
}
