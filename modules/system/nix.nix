{ nixpkgsRegistry, unstablePkgs, ... }:
{
  nix = {
    # Use the latest released Nix rather than the older default or a prerelease.
    package = unstablePkgs.nixVersions.latest;
    optimise.automatic = true;
    registry.nixpkgs.flake = nixpkgsRegistry;
    settings = import ../../lib/nix-settings.nix;
  };
}
