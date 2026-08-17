{ pkgs, ... }:
{
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
}
