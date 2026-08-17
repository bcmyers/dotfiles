{
  description = "Brian Myers' NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    prompt-src = {
      url = "github:bcmyers/prompt/v0.1.0";
      flake = false;
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
      home-manager-unstable,
      nix-darwin,
      nixos-hardware,
      nixpkgs,
      nixpkgs-unstable,
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
        nixpkgsInput: system:
        import nixpkgsInput {
          inherit system;
          config.allowUnfree = false;
        };
      mkHomeSpecialArgs = system: {
        inherit
          inputs
          ;
        unstablePkgs = mkPkgs nixpkgs-unstable system;
        promptPackage = mkPrompt system;
      };
      mkPrompt =
        system:
        (mkPkgs nixpkgs-unstable system).callPackage ./pkgs/prompt {
          src = inputs.prompt-src;
        };
      mkHomeConfiguration =
        {
          homeManager,
          homeModule,
          nixpkgsInput,
          system,
        }:
        homeManager.lib.homeManagerConfiguration {
          pkgs = mkPkgs nixpkgsInput system;
          extraSpecialArgs = mkHomeSpecialArgs system;
          modules = [ homeModule ];
        };
      workMacHomeConfiguration = mkHomeConfiguration {
        homeManager = home-manager-unstable;
        homeModule = ./hosts/work-mac/home.nix;
        nixpkgsInput = nixpkgs-unstable;
        system = macSystem;
      };
      workDevboxHomeConfiguration = mkHomeConfiguration {
        homeManager = home-manager-unstable;
        homeModule = ./hosts/work-devbox/home.nix;
        nixpkgsInput = nixpkgs-unstable;
        system = linuxSystem;
      };
      nixosConfiguration = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = (mkHomeSpecialArgs linuxSystem) // {
          nixpkgsRegistry = inputs.nixpkgs;
        };
        modules = [
          disko.nixosModules.disko
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme
          home-manager.nixosModules.home-manager
          ./modules/system
          ./hosts/thinkpad
        ];
      };
      personalMacConfiguration = nix-darwin.lib.darwinSystem {
        specialArgs = (mkHomeSpecialArgs macSystem) // {
          nixpkgsRegistry = inputs.nixpkgs-unstable;
        };
        modules = [
          home-manager-unstable.darwinModules.home-manager
          ./modules/system
          ./hosts/personal-mac
        ];
      };
    in
    {
      homeConfigurations = {
        "brian.myers@work-mac" = workMacHomeConfiguration;
        "root@work-devbox" = workDevboxHomeConfiguration;
      };
      darwinConfigurations.personal-mac = personalMacConfiguration;
      nixosConfigurations.thinkpad = nixosConfiguration;

      checks.${linuxSystem} = {
        disko-test = nixosConfiguration.config.system.build.installTest;
        prompt = mkPrompt linuxSystem;
        thinkpad = nixosConfiguration.config.system.build.toplevel;
        vm = nixosConfiguration.config.system.build.vm;
        work-devbox = workDevboxHomeConfiguration.activationPackage;
      };
      checks.${macSystem} = {
        personal-mac = personalMacConfiguration.system;
        prompt = mkPrompt macSystem;
        work-mac = workMacHomeConfiguration.activationPackage;
      };

      formatter = nixpkgs.lib.genAttrs formatterSystems (
        formatterSystem: nixpkgs.legacyPackages.${formatterSystem}.nixfmt-tree
      );

      packages.${linuxSystem} = {
        default = nixosConfiguration.config.system.build.toplevel;
        disko = disko.packages.${linuxSystem}.disko;
        disko-test = nixosConfiguration.config.system.build.installTest;
        prompt = mkPrompt linuxSystem;
        vm = nixosConfiguration.config.system.build.vm;
      };
      packages.${macSystem} = {
        default = personalMacConfiguration.system;
        prompt = mkPrompt macSystem;
      };

      apps = nixpkgs.lib.genAttrs formatterSystems (
        system:
        {
          age-keygen = {
            type = "app";
            program = "${(mkPkgs nixpkgs-unstable system).age}/bin/age-keygen";
            meta.description = "Run the age key generator pinned by this flake";
          };
          home-manager = {
            type = "app";
            program = "${home-manager-unstable.packages.${system}.home-manager}/bin/home-manager";
            meta.description = "Run Home Manager using this flake's pinned version";
          };
          sops = {
            type = "app";
            program = "${(mkPkgs nixpkgs-unstable system).sops}/bin/sops";
            meta.description = "Run the SOPS version pinned by this flake";
          };
        }
        // nixpkgs.lib.optionalAttrs (system == linuxSystem) {
          nixos-install = {
            type = "app";
            program = "${nixosConfiguration.config.system.build.nixos-install}/bin/nixos-install";
            meta.description = "Install the ThinkPad NixOS configuration";
          };
          nixos-rebuild = {
            type = "app";
            program = "${nixosConfiguration.config.system.build.nixos-rebuild}/bin/nixos-rebuild";
            meta.description = "Build and activate the ThinkPad NixOS configuration";
          };
        }
        // nixpkgs.lib.optionalAttrs (system == macSystem) {
          darwin-rebuild = {
            type = "app";
            program = "${nix-darwin.packages.${macSystem}.darwin-rebuild}/bin/darwin-rebuild";
            meta.description = "Build and activate this flake's nix-darwin configuration";
          };
        }
      );
    };
}
