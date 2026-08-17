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
      linuxSystem = "x86_64-linux";
      macSystem = "aarch64-darwin";
      formatterSystems = [
        linuxSystem
        macSystem
      ];
      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = false;
        };
      mkHomeConfiguration =
        {
          homeDirectory,
          system,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = {
            inherit homeDirectory;
            inherit inputs;
            isNixOS = false;
          };
          modules = [ ./home.nix ];
        };
      linuxHomeConfiguration = mkHomeConfiguration {
        homeDirectory = "/home/bcmyers";
        system = linuxSystem;
      };
      macHomeConfiguration = mkHomeConfiguration {
        homeDirectory = "/Users/bcmyers";
        system = macSystem;
      };
      nixosConfiguration = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
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
      homeConfigurations = {
        "bcmyers@linux" = linuxHomeConfiguration;
        "bcmyers@mac" = macHomeConfiguration;
      };
      nixosConfigurations.thinkpad = nixosConfiguration;

      checks.${linuxSystem} = {
        disko-install = nixosConfiguration.config.system.build.installTest;
        home = linuxHomeConfiguration.activationPackage;
        nixos = nixosConfiguration.config.system.build.toplevel;
        vm = nixosConfiguration.config.system.build.vm;
      };
      checks.${macSystem}.home = macHomeConfiguration.activationPackage;

      formatter = nixpkgs.lib.genAttrs formatterSystems (
        formatterSystem: nixpkgs.legacyPackages.${formatterSystem}.nixfmt-tree
      );

      packages.${linuxSystem} = {
        default = nixosConfiguration.config.system.build.toplevel;
        disko = disko.packages.${linuxSystem}.disko;
        disko-test = nixosConfiguration.config.system.build.installTest;
        home-manager = home-manager.packages.${linuxSystem}.home-manager;
        vm = nixosConfiguration.config.system.build.vm;
      };
      packages.${macSystem}.home-manager = home-manager.packages.${macSystem}.home-manager;

      apps = nixpkgs.lib.genAttrs formatterSystems (system: {
        default = {
          type = "app";
          program = "${home-manager.packages.${system}.home-manager}/bin/home-manager";
          meta.description = "Run Home Manager using this flake's pinned version";
        };
      });
    };
}
