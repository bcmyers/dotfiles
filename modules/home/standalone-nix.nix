{
  inputs,
  pkgs,
  ...
}:
{
  nix = {
    package = pkgs.nix;

    registry.nixpkgs.flake =
      if pkgs.stdenv.hostPlatform.isDarwin then inputs.nixpkgs-unstable else inputs.nixpkgs;

    settings = import ../../lib/nix-settings.nix;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
