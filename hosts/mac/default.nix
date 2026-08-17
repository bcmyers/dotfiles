{
  pkgs,
  ...
}:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.bcmyers = {
    home = "/Users/bcmyers";
    shell = pkgs.fish;
  };

  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 3;
      Minute = 0;
    };
    options = "--delete-older-than 30d";
  };

  system = {
    primaryUser = "bcmyers";
    stateVersion = 6;
  };
}
