{ inputs, pkgs }:
pkgs.testers.runNixOSTest {
  name = "cosmic-remote-desktop-portal";
  globalTimeout = 300;
  node.pkgs = pkgs.lib.mkForce (
    pkgs.appendOverlays (
      (import ../hosts/thinkpad/cosmic-packages.nix { inherit inputs; }).nixpkgs.overlays
    )
  );

  nodes.machine = {
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
    # Disposable test account only; the ThinkPad keeps its normal login.
    services.displayManager.autoLogin = {
      enable = true;
      user = "alice";
    };
    users.users.alice = {
      isNormalUser = true;
      uid = 1000;
      password = "test-only";
    };
    services.pipewire.enable = true;
    virtualisation.memorySize = 4096;
    virtualisation.cores = 2;
  };

  testScript = ''
    machine.wait_for_unit("graphical.target")
    # Nix wrappers change the kernel process name; match the preserved command line.
    machine.wait_until_succeeds("pgrep -u alice -f '(^|/)cosmic-comp( |$)'")
    user_bus = "su - alice -c 'XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus "
    with subtest("COSMIC exposes remote keyboard and pointer control"):
        devices_command = user_bus + "busctl --user get-property org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.RemoteDesktop AvailableDeviceTypes'"
        machine.wait_until_succeeds(devices_command)
        device_types = int(machine.succeed(devices_command).split()[1])
        assert device_types & 3 == 3, device_types  # keyboard and pointer
        interface = machine.succeed(user_bus + "busctl --user introspect org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.RemoteDesktop'")
        for method in ["CreateSession", "SelectDevices", "ConnectToEIS", "NotifyPointerMotionAbsolute", "NotifyKeyboardKeycode"]:
            assert method in interface, interface
    with subtest("Panel and screen capture start with the desktop"):
        machine.wait_until_succeeds("pgrep -u alice -f '(^|/)cosmic-panel( |$)'")
        machine.succeed(user_bus + "busctl --user get-property org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.ScreenCast AvailableSourceTypes'")
  '';
}
