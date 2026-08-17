{ lib, ... }:
{
  services.fstrim.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  disko = {
    tests = {
      bootCommands = ''
        machine.wait_for_text("[Pp]assphrase for")
        machine.send_chars("secretsecret\n")
      '';
      enableOCR = true;
      # Disko's install-test harness uses a 4 GiB virtual disk, so exercise the
      # same swapfile declaration at 1 GiB while retaining 8 GiB in production.
      extraConfig.swapDevices = lib.mkForce [
        {
          device = "/var/lib/swapfile";
          size = 1024;
        }
      ];
      extraChecks = ''
        machine.succeed("cryptsetup isLuks /dev/vda2")
        machine.succeed("test $(findmnt -n -o FSTYPE /) = ext4")
        machine.succeed("test -f /var/lib/swapfile")
        machine.succeed("grep -q /var/lib/swapfile /proc/swaps")
      '';
    };
  };

  disko.devices.disk.main = {
    type = "disk";

    # This is the only internal drive in the ThinkPad. The installation
    # runbook requires verifying its model and size immediately before Disko.
    device = "/dev/nvme0n1";

    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          name = "ESP";
          start = "1M";
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        cryptroot = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            # Disko's install test creates a dummy value at this path. The
            # physical installer supplies the real passphrase in live memory.
            passwordFile = "/tmp/secret.key";
            settings.allowDiscards = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "noatime" ];
            };
          };
        };
      };
    };
  };
}
