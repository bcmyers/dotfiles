{ lib, ... }:
{
  imports = [
    ../../modules/home
    ../../modules/home/packages/development.nix
  ];

  # Preserve platform-provided root startup files. Fish remains available as
  # an explicitly launched, Home Manager-managed shell.
  programs.bash.enable = lib.mkForce false;
}
