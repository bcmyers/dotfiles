{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./disko.nix ];

  boot = {
    initrd.systemd.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 8;
      };
    };
  };

  console.keyMap = "us";

  environment.systemPackages = with pkgs; [
    cryptsetup
    efibootmgr
    git
    pciutils
    usbutils
    vim
  ];

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    enableRedistributableFirmware = true;
    graphics.enable = true;
    nvidia = {
      branch = "legacy_580";
      modesetting.enable = true;
      nvidiaSettings = true;
      open = false;
      powerManagement.enable = true;
    };
  };

  home-manager = {
    backupFileExtension = "home-manager-backup";
    extraSpecialArgs = {
      inherit inputs;
      isNixOS = true;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.bcmyers = import ../../home.nix;
  };

  networking = {
    hostName = "thinkpad";
    networkmanager.enable = true;
    firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ ];
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    registry.nixpkgs.flake = inputs.nixpkgs;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      keep-derivations = true;
      keep-outputs = true;
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-kernel-modules"
      "nvidia-settings"
      "nvidia-x11"
    ];

  programs = {
    fish.enable = true;
    virt-manager.enable = true;
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
    sudo.wheelNeedsPassword = true;
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    desktopManager.cosmic.enable = true;
    displayManager.cosmic-greeter.enable = true;
    fstrim.enable = true;
    fwupd.enable = true;
    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    power-profiles-daemon.enable = true;
    printing.enable = true;
    tailscale.enable = true;
    thermald.enable = true;
    upower.enable = true;
    xserver = {
      videoDrivers = [ "nvidia" ];
      xkb.layout = "us";
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  time.timeZone = "America/New_York";

  users = {
    mutableUsers = true;
    users.bcmyers = {
      isNormalUser = true;
      description = "Brian Myers";
      extraGroups = [
        "libvirtd"
        "networkmanager"
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKA36iCRBr68DR9FP6UrVHPbhfKpxBOz9vvimZsm8CCl brian.myers@post.harvard.edu"
      ];
      shell = pkgs.fish;
    };
  };

  virtualisation = {
    libvirtd.enable = true;

    # `nix build .#vm` uses this safe, headless variant. Disko is disabled and
    # QEMU supplies a disposable virtual disk; the production disk is untouched.
    vmVariant = {
      disko.enableConfig = lib.mkForce false;
      hardware.nvidia.powerManagement.enable = lib.mkForce false;
      networking = {
        hostName = lib.mkForce "thinkpad-vm";
        firewall.allowedTCPPorts = lib.mkForce [ 22 ];
      };
      services = {
        desktopManager.cosmic.enable = lib.mkForce false;
        displayManager.cosmic-greeter.enable = lib.mkForce false;
        getty.autologinUser = "bcmyers";
        openssh.settings.PasswordAuthentication = lib.mkForce true;
        xserver.videoDrivers = lib.mkForce [ "modesetting" ];
      };
      users.users.bcmyers.initialPassword = "nixos-vm";
      virtualisation = {
        cores = 4;
        diskSize = 16384;
        forwardPorts = [
          {
            from = "host";
            host.port = 2222;
            guest.port = 22;
          }
        ];
        graphics = false;
        memorySize = 4096;
      };
    };
  };

  system.stateVersion = "26.05";
}
