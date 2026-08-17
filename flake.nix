{
  description = "Brian Myers' NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      disko,
      home-manager,
      nixos-hardware,
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
        extraSpecialArgs = {
          inherit inputs;
          isNixOS = false;
        };
        modules = [ ./home.nix ];
      };
      nixosConfiguration = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme
          home-manager.nixosModules.home-manager
          ./hosts/thinkpad
        ];
      };
    in
    {
      homeConfigurations."bcmyers@linux" = homeConfiguration;
      nixosConfigurations.thinkpad = nixosConfiguration;

      checks.${system} = {
        disko-install = nixosConfiguration.config.system.build.installTest;
        home = homeConfiguration.activationPackage;
        nixos = nixosConfiguration.config.system.build.toplevel;
        vm = nixosConfiguration.config.system.build.vm;
      };

      formatter = nixpkgs.lib.genAttrs formatterSystems (
        formatterSystem: nixpkgs.legacyPackages.${formatterSystem}.nixfmt-tree
      );

      packages.${system} = {
        default = nixosConfiguration.config.system.build.toplevel;
        disko = disko.packages.${system}.disko;
        disko-test = nixosConfiguration.config.system.build.installTest;
        home-manager = home-manager.packages.${system}.home-manager;
        vm = nixosConfiguration.config.system.build.vm;
      };

      apps.${system}.default = {
        type = "app";
        program = "${home-manager.packages.${system}.home-manager}/bin/home-manager";
        meta.description = "Run Home Manager using this flake's pinned version";
      };
    };
}
