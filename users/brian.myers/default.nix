{
  homeDirectory,
  ...
}:
{
  imports = [ ../../modules/home ];

  home = {
    username = "brian.myers";
    inherit homeDirectory;

    # This controls compatibility defaults, not installed package versions.
    stateVersion = "26.05";
  };

  programs.git.settings.user.email = "brian.myers@robinhood.com";
}
