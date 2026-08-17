{
  homeDirectory,
  isDarwin,
  isSystemManaged,
  lib,
  ...
}:
{
  imports = [
    ./core.nix
    ./packages.nix
    ./programs/editor.nix
    ./programs/git.nix
    ./programs/security.nix
    ./programs/shell.nix
    ./programs/terminal.nix
    ./secrets.nix
  ]
  ++ lib.optional (!isSystemManaged) ./standalone-nix.nix
  ++ lib.optional isDarwin ./platform/darwin.nix
  ++ lib.optional (!isDarwin) ./platform/linux.nix;

  home = {
    username = "bcmyers";
    inherit homeDirectory;

    # This controls compatibility defaults, not the versions of installed
    # packages. Do not bump it without reading the Home Manager release notes.
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
