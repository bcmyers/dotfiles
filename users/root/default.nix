{
  imports = [
    ../../modules/home
    ../brian.myers/identity.nix
  ];

  home = {
    username = "root";

    # This controls compatibility defaults, not installed package versions.
    stateVersion = "26.05";
  };
}
