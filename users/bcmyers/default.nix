{
  imports = [
    ../../modules/home
    ./aws.nix
    ./identity.nix
    ./neovim.nix
    ./secrets.nix
    ./security.nix
  ];

  home = {
    username = "bcmyers";

    # This controls compatibility defaults, not installed package versions.
    stateVersion = "26.05";
  };
}
