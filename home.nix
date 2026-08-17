{
  homeDirectory,
  isNixOS,
  lib,
  ...
}:
{
  imports = [
    ./home/core.nix
    ./home/packages.nix
    ./home/programs.nix
  ]
  ++ lib.optional (!isNixOS) ./home/nix.nix;

  home = {
    username = "bcmyers";
    inherit homeDirectory;

    # This controls compatibility defaults, not the versions of installed
    # packages. Do not bump it without reading the Home Manager release notes.
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
