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

  # Homebrew remains the delivery mechanism for self-updating macOS apps that
  # are intentionally outside the Nix store. Undeclared casks are uninstalled
  # on activation, but their application support data is preserved.
  homebrew = {
    enable = true;
    casks = [
      "codex"
      "discord"
      "dropbox"
      "firefox"
      "notion"
      "obsidian"
      "opensuperwhisper"
      "rustdesk"
      "signal"
      "slack"
      "whatsapp"
    ];
    onActivation = {
      cleanup = "uninstall";
    };
  };

  home-manager.users.bcmyers = {
    imports = [
      ../../modules/home/apps/alacritty.nix
      ../../modules/home/apps/darwin.nix
      ../../modules/home/apps/rustdesk.nix
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
