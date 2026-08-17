{
  inputs,
  pkgs,
  ...
}:
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  programs.fish.enable = true;

  users.users.bcmyers = {
    home = "/Users/bcmyers";
    shell = pkgs.fish;
  };

  home-manager = {
    backupFileExtension = "home-manager-backup";
    extraSpecialArgs = {
      homeDirectory = "/Users/bcmyers";
      inherit inputs;
      isDarwin = true;
      isSystemManaged = true;
      unstablePkgs = pkgs;
    };
    sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    useGlobalPkgs = true;
    useUserPackages = true;
    users.bcmyers = import ../../home.nix;
  };

  nix = {
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    registry.nixpkgs.flake = inputs.nixpkgs-unstable;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      keep-derivations = true;
      keep-outputs = true;
    };
  };

  system = {
    primaryUser = "bcmyers";
    stateVersion = 6;
  };
}
