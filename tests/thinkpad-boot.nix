{ inputs, pkgs }:
let
  upstream = inputs.lanzaboote;
  recovery = pkgs.writeText "test-only-recovery-passphrase" "secretsecret";
in
pkgs.testers.runNixOSTest {
  name = "thinkpad-secure-boot-tpm";
  globalTimeout = 600;
  extraBaseModules = {
    imports = [ upstream.nixosModules.lanzaboote ];
  };

  nodes.machine = { lib, ... }: {
    imports = [
      "${upstream}/nix/tests/lanzaboote/common/lanzaboote.nix"
      ../hosts/thinkpad/boot.nix
      ../hosts/thinkpad/availability.nix
    ];
    # Upstream public test fixtures, never production keys. The disposable
    # firmware enrolls these fixtures when the test image first boots.
    boot.lanzaboote.pkiBundle = lib.mkForce "/var/lib/lanzaboote-test-fixture";
    lanzabooteTest.persistentRoot = true;
    image.repart.partitions.root.repartConfig.SizeMinBytes = lib.mkForce "512M";
    virtualisation = {
      tpm.enable = true;
      emptyDiskImages = [ 128 ];
      memorySize = 2048;
    };
    users.users.bcmyers.isNormalUser = true;
    environment.systemPackages = [
      pkgs.cryptsetup
      pkgs.jq
    ];
    environment.etc."test-only-recovery-passphrase".source = recovery;

    # Boot another signed configuration after provisioning the empty test disk.
    # Its initrd must unlock that disk without asking for a password.
    specialisation.encrypted.configuration.boot.initrd.luks.devices.cryptroot = {
      device = "/dev/vdb";
      crypttabExtraOpts = [
        "tpm2-device=auto"
        "token-timeout=10s"
      ];
    };
  };

  testScript =
    { nodes, ... }:
    (import "${upstream}/nix/tests/lanzaboote/common/image-helper.nix" { inherit (nodes) machine; })
    + ''
      import json

      machine.wait_for_unit("multi-user.target")
      with subtest("Signed boot and services work without a desktop login"):
          machine.succeed("systemd-analyze condition ConditionSecurity=uefi-secureboot")
          machine.succeed("systemd-analyze condition ConditionSecurity=measured-uki")
          machine.wait_for_unit("upower.service")
          machine.succeed("test -e /var/lib/systemd/linger/bcmyers")
          machine.succeed("grep -q 'AllowSuspend=false' /etc/systemd/sleep.conf")
          machine.succeed("grep -q 'CriticalPowerAction=PowerOff' /etc/UPower/UPower.conf")

      with subtest("Enroll the production PCR policy in a disposable LUKS volume"):
          machine.succeed("cryptsetup luksFormat --batch-mode --type luks2 --pbkdf pbkdf2 --key-file ${recovery} /dev/vdb")
          machine.succeed("systemd-cryptenroll --unlock-key-file=${recovery} --tpm2-device=auto --tpm2-pcrs=0:sha256+7:sha256 --tpm2-with-pin=no /dev/vdb")
          metadata = json.loads(machine.succeed("cryptsetup luksDump --dump-json-metadata /dev/vdb"))
          token = next(t for t in metadata["tokens"].values() if t["type"] == "systemd-tpm2")
          assert token["tpm2-pcrs"] == [0, 7], token
          assert token.get("tpm2-pin", False) is False, token

      with subtest("Another signed OS configuration unlocks in initrd unattended"):
          # The fixture image has a read-only Nix store. Select the already
          # signed specialisation through systemd-boot, as upstream tests do.
          machine.succeed("bootctl set-default 'nixos-generation-1-specialisation-encrypted-*.efi'")
          machine.reboot()
          machine.wait_for_unit("multi-user.target")
          machine.succeed("cryptsetup status cryptroot")
          machine.succeed("systemd-analyze condition ConditionSecurity=uefi-secureboot")

      with subtest("Changed trust measurements reject TPM unlock; recovery still works"):
          # This test volume is not mounted; close its initrd mapping first.
          machine.succeed("cryptsetup close cryptroot")
          machine.succeed("${pkgs.systemd}/lib/systemd/systemd-cryptsetup attach accepted /dev/vdb - tpm2-device=auto,headless=yes")
          machine.succeed("${pkgs.systemd}/lib/systemd/systemd-cryptsetup detach accepted")
          machine.succeed("tpm2_pcrextend 7:sha256=" + "00" * 32)
          machine.fail("${pkgs.systemd}/lib/systemd/systemd-cryptsetup attach rejected /dev/vdb - tpm2-device=auto,headless=yes")
          machine.succeed("cryptsetup open --test-passphrase --disable-external-tokens --key-file ${recovery} /dev/vdb")

      with subtest("A cold boot restores normal automatic unlocking"):
          machine.shutdown()
          machine.start()
          machine.wait_for_unit("multi-user.target")
          machine.succeed("cryptsetup status cryptroot")

      with subtest("A modified initrd is rejected by the signed boot chain"):
          machine.succeed('for image in /boot/EFI/nixos/initrd-*.efi; do printf tampered >> "$image"; done; sync')
          machine.crash()
          machine.start()
          machine.wait_for_console_text("hash does not match")
    '';
}
