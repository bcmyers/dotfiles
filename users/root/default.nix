{
  imports = [
    ../../profiles/home/identities/openai.nix
    ../../profiles/home/work-devbox.nix
  ];

  home = {
    username = "root";

    # This controls compatibility defaults, not installed package versions.
    stateVersion = "26.05";
  };
}
