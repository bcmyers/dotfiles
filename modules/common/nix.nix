{ nixpkgsRegistry, ... }:
{
  nix = {
    optimise.automatic = true;
    registry.nixpkgs.flake = nixpkgsRegistry;
    settings = import ../../lib/nix-settings.nix;
  };
}
