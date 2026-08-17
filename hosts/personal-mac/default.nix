{
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Keep Homebrew available during the migration, but after every Nix profile
  # so Nix-managed executables always take precedence.
  environment.systemPath = lib.mkAfter [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];
  environment.shells = [ pkgs.fish ];

  home-manager.users.bcmyers = {
    imports = [
      ../../modules/home/apps/alacritty.nix
      ../../modules/home/apps/darwin.nix
      ../../users/bcmyers
    ];
    home.homeDirectory = "/Users/bcmyers";
  };

  users.users.bcmyers.home = "/Users/bcmyers";

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
