{
  homeDirectory,
  inputs,
  isDarwin,
  nixpkgsRegistry,
  unstablePkgs,
  ...
}:
{
  home-manager = {
    backupFileExtension = "home-manager-backup";
    extraSpecialArgs = {
      inherit
        homeDirectory
        inputs
        isDarwin
        unstablePkgs
        ;
      isSystemManaged = true;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.bcmyers = import ../../home.nix;
  };

  nix = {
    optimise.automatic = true;
    registry.nixpkgs.flake = nixpkgsRegistry;
    settings = import ../../lib/nix-settings.nix;
  };

  programs.fish.enable = true;
}
