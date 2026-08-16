{
  imports = [
    ./home/core.nix
    ./home/nix.nix
    ./home/packages.nix
    ./home/programs.nix
  ];

  home = {
    username = "bcmyers";
    homeDirectory = "/home/bcmyers";

    # This controls compatibility defaults, not the versions of installed
    # packages. Do not bump it without reading the Home Manager release notes.
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
