"""Disposable COSMIC VM only: real VNC capture, authentication and consent persistence."""
import shlex
from typing import Any, cast
from PIL import Image, ImageChops, ImageStat


def desktop(command):
    env = "XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus "
    return machine.succeed("su - alice -c " + shlex.quote(env + command))


def click_vm(x, y):
    # QMP accepts nested JSON; the driver incorrectly annotates values as str.
    qmp = cast(Any, machine.qmp_client)
    assert qmp is not None
    # NixOS's default virtual display is 1280x800. Only initial consent uses QMP.
    qmp.send("input-send-event", {"events": [
        {"type": "abs", "data": {"axis": "x", "value": round(x * 32767 / 1280)}},
        {"type": "abs", "data": {"axis": "y", "value": round(y * 32767 / 800)}},
    ]})
    for down in (True, False):
        qmp.send("input-send-event", {"events": [
            {"type": "btn", "data": {"button": "left", "down": down}},
        ]})


def start_sharing():
    # Software rendering is confined to the VM, which has no physical GPU.
    desktop("systemd-run --user --unit=krfb-test --collect --property=Type=exec "
            "--setenv=QT_QPA_PLATFORM=wayland --setenv=LIBGL_ALWAYS_SOFTWARE=1 "
            "--setenv=GALLIUM_DRIVER=llvmpipe --setenv=QT_LOGGING_RULES='krfb.*=true' "
            + krfb + " --nodialog")


def vnc(arguments, password="vmtest42"):
    # Public disposable-test credential; never used on the physical ThinkPad.
    machine.succeed(vncdo + " -t 15 -s 127.0.0.1 -p " + shlex.quote(password)
                    + " " + arguments + " pause 1", timeout=25)


def capture(name):
    vnc("capture /tmp/" + name + ".png")
    # vncdotool can return zero even when authentication fails: require output.
    machine.succeed("test -s /tmp/" + name + ".png")
    machine.copy_from_machine("/tmp/" + name + ".png")


with subtest("Approve COSMIC once in the disposable VM"):
    # Initial setup may start after the panel; it is irrelevant to this test.
    machine.sleep(5)
    machine.execute("pkill -u alice -f '(^|/)cosmic-initial-setup( |$)'")
    obscured = "".join(chr(0x1001F - ord(c)) for c in "vmtest42")
    config = ("[TCP]\nuseDefaultPort=true\npublishService=false\n"
              "[Security]\nnoWallet=true\nallowDesktopControl=true\n"
              "allowUnattendedAccess=true\nunattendedPassword=" + obscured
              + "\n[FrameBuffer]\npreferredFrameBufferPlugin=pw\n")
    desktop("install -d -m 700 ~/.config")
    desktop("umask 077; printf %s " + shlex.quote(config) + " > ~/.config/krfbrc")
    start_sharing()
    machine.wait_for_text("Allow remote control", timeout=60)
    machine.screenshot("first-consent")
    click_vm(620, 440)
    machine.sleep(1)
    click_vm(841, 672)
    machine.wait_until_succeeds("test -s /home/alice/.local/state/krfbstaterc", timeout=60)

with subtest("Password authentication and complete framebuffer"):
    vnc("capture /tmp/wrong-password.png", password="wrongpwd")
    machine.succeed("test ! -e /tmp/wrong-password.png")
    assert "password check failed" in desktop("journalctl --user -u krfb-test --no-pager")
    capture("vnc-desktop")
    machine.screenshot("local-desktop")
    # Exclude the moving cursor, clock, and transient notification area.
    crop = (80, 80, 450, 650)
    local = Image.open(machine.out_dir / "local-desktop.png").convert("RGB")
    remote = Image.open(machine.out_dir / "vnc-desktop.png").convert("RGB")
    assert local.size == remote.size == (1280, 800)
    assert max(ImageStat.Stat(remote.crop(crop)).stddev) > 10, "blank capture"
    difference = ImageChops.difference(local.crop(crop), remote.crop(crop))
    assert max(ImageStat.Stat(difference).mean) < 3, "VNC pixels differ from desktop"

with subtest("Reconnect after app restart without another approval"):
    desktop("systemctl --user stop krfb-test")
    start_sharing()
    # Do not click or dismiss any portal here: capture and input must recover.
    machine.sleep(3)
    capture("vnc-after-restart")
    restored = Image.open(machine.out_dir / "vnc-after-restart.png").convert("RGB")
    assert restored.size == remote.size
    difference = ImageChops.difference(remote.crop(crop), restored.crop(crop))
    assert max(ImageStat.Stat(difference).mean) < 3, "capture did not recover"
    desktop("systemctl --user stop krfb-test")
