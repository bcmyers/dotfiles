{
  programs.git = {
    signing = {
      format = "openpgp";
      key = "B86678B99457460F";
      signByDefault = true;
    };
    settings.user = {
      email = "brian.carl.myers@gmail.com";
      name = "Brian Myers";
    };
  };
}
