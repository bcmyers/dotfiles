{ lib, ... }:
{
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;

  # `nix build .#vm` uses this safe, headless variant. Disko is disabled and
  # QEMU supplies a disposable virtual disk; the production disk is untouched.
  virtualisation.vmVariant = {
    boot.lanzaboote.enable = lib.mkForce false;
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
      openssh.settings.PasswordAuthentication = lib.mkForce false;
      xserver.videoDrivers = lib.mkForce [ "modesetting" ];
    };
    users.users.bcmyers.initialPassword = "nixos-vm";
    virtualisation = {
      cores = 4;
      diskSize = 16384;
      forwardPorts = [
        {
          from = "host";
          host = {
            address = "127.0.0.1";
            port = 2222;
          };
          guest.port = 22;
        }
      ];
      graphics = false;
      memorySize = 4096;
    };
  };
}
