{ config, ... }:
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
      openssh.authorizedKeys.keyFiles = [
        ../../files/ssh/macbook.pub
      ];
      shell = config.programs.fish.package;
    };
  };
}
