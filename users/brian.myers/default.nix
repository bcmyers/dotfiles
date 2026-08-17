{
  imports = [
    ../../modules/home
    ./identity.nix
  ];

  home = {
    username = "brian.myers";

    # This controls compatibility defaults, not installed package versions.
    stateVersion = "26.05";
  };
}
