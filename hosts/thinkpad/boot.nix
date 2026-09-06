{ lib, pkgs, ... }:
{
  boot = {
    initrd.systemd = {
      enable = true;
      tpm2.enable = true;
      emergencyAccess = false;
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = lib.mkForce false;
        configurationLimit = 8;
        editor = false;
      };
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      allowUnsigned = false;
      configurationLimit = 8;
      # This ThinkPad's TPM lacks PolicyAuthorizeNV (systemd-pcrlock).
      # Enrollment instead binds to PCRs 0+7 after Secure Boot is enabled.
      measuredBoot.enable = false;
      autoGenerateKeys.enable = false;
      autoEnrollKeys.enable = false;
    };
  };

  security.tpm2.enable = true;
  environment.systemPackages = [
    pkgs.sbctl
    pkgs.tpm2-tools
  ];
}
