{
  description = "Brian Myers' standalone Home Manager configuration for Linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      home-manager,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      formatterSystems = [
        system
        "aarch64-darwin"
      ];
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = false;
      };
      homeConfiguration = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    in
    {
      homeConfigurations."bcmyers@linux" = homeConfiguration;

      checks.${system}.home = homeConfiguration.activationPackage;

      formatter = nixpkgs.lib.genAttrs formatterSystems (
        formatterSystem: nixpkgs.legacyPackages.${formatterSystem}.nixfmt-tree
      );

      packages.${system}.home-manager = home-manager.packages.${system}.home-manager;

      apps.${system}.default = {
        type = "app";
        program = "${home-manager.packages.${system}.home-manager}/bin/home-manager";
        meta.description = "Run Home Manager using this flake's pinned version";
      };
    };
}
