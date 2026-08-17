{
  homeDirectory,
  ...
}:
{
  imports = [
    ../../modules/home
    ./secrets.nix
  ];

  home = {
    username = "bcmyers";
    inherit homeDirectory;

    # This controls compatibility defaults, not installed package versions.
    stateVersion = "26.05";
  };

  programs.git.settings.user.email = "brian.carl.myers@gmail.com";
}
