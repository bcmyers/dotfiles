{
  config,
  lib,
  pkgs,
  unstablePkgs,
  ...
}:
let
  controller = pkgs.stdenv.hostPlatform.isDarwin;
  python = pkgs.python3.withPackages (ps: [ ps.tomli-w ]);
  configDirectory =
    if controller then
      "${config.home.homeDirectory}/Library/Preferences/com.carriez.RustDesk"
    else
      "${config.xdg.configHome}/rustdesk";
in
{
  # macOS receives the GUI app from the personal Mac's Homebrew cask list.
  home.packages = lib.optionals (!controller) [ unstablePkgs.rustdesk-flutter ];

  # RustDesk rewrites this file, so use a merge instead of a read-only symlink.
  # No password or generated identity is stored in the repository/Nix store.
  home.activation.rustdeskPrivateNetworking = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${python}/bin/python ${../../../scripts/configure-rustdesk-private.py} \
      ${lib.escapeShellArg configDirectory} ${if controller then "controller" else "host"}
  '';
}
