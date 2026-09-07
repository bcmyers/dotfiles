{ inputs, lib, ... }:
{
  services.fstrim.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 64 * 1024;
    }
  ];

  disko = {
    tests = {
      efi = true;
      bootCommands = ''
        machine.wait_for_text("[Pp]assphrase for")
        machine.send_chars("secretsecret\n")
      '';
      enableOCR = true;
      # Disko's install-test harness uses a 4 GiB virtual disk, so exercise the
      # same swapfile declaration at 1 GiB while retaining 64 GiB in production.
      extraConfig = {
        swapDevices = lib.mkForce [
          {
            device = "/var/lib/swapfile";
            size = 1024;
          }
        ];
        # Public upstream test fixtures only; no production signing key enters
        # the Nix store. This test boots with firmware enforcement disabled.
        boot.lanzaboote = {
          publicKeyFile = "${inputs.lanzaboote}/nix/tests/fixtures/uefi-keys/keys/db/db.pem";
          privateKeyFile = "${inputs.lanzaboote}/nix/tests/fixtures/uefi-keys/keys/db/db.key";
        };
      };
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

    # Match the physical disk even if another drive changes device numbering.
    # Verify its model, serial, and size before invoking Disko.
    device = "/dev/disk/by-id/nvme-WDC_PC_SN720_SDAQNTW-512G-1001_184521422453";

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
            settings = {
              allowDiscards = true;
              crypttabExtraOpts = [
                "tpm2-device=auto"
                "token-timeout=10s"
              ];
            };
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
