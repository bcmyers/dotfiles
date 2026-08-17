{ pkgs, ... }:
{
  imports = [
    ./boot.nix
    ./desktop.nix
    ./disko.nix
    ./hardware.nix
    ./networking.nix
    ./users.nix
    ./virtualization.nix
  ];

  console.keyMap = "us";

  environment.systemPackages = with pkgs; [
    cryptsetup
    efibootmgr
    git
    pciutils
    usbutils
    vim
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "26.05";
  time.timeZone = "America/New_York";
}
