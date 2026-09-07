# COSMIC remote desktop

The ThinkPad stays on COSMIC. Its stable NixOS input supplies COSMIC 1.2,
which has screen capture but no RemoteDesktop portal. COSMIC 1.7 adds the
portal needed for remote keyboard and pointer control.

`hosts/thinkpad/cosmic-packages.nix` temporarily imports the coherent COSMIC
package set from the pinned revision of
[Nixpkgs PR 556651](https://github.com/NixOS/nixpkgs/pull/556651). The kernel,
NixOS modules, Secure Boot configuration, and disk unlocking configuration
continue to come from the existing stable inputs. Remove this extra package
pin when the normal Nixpkgs input supplies COSMIC 1.7 or newer.

Upstream references:

1. [COSMIC 1.7 release](https://github.com/pop-os/cosmic-epoch/releases/tag/epoch-1.7.0)
2. [COSMIC RemoteDesktop portal implementation and RustDesk testing](https://github.com/pop-os/xdg-desktop-portal-cosmic/pull/317)
3. [Compositor support for remote input](https://github.com/pop-os/cosmic-comp/pull/2442)

## Build and verify

On the ThinkPad, from this repository:

```sh
just build-thinkpad
just test-cosmic-remote-desktop
```

Run these sequentially. They retain separate GC roots, `result-thinkpad` and
`result-cosmic-remote-desktop`. Keep those links until installation and testing
finish. The complete upgrade helper instead retains both results outside the
checkout under `~/.local/state/thinkpad-install/builds/<revision>/`.

The ThinkPad now has a 64 GiB swap file. Both recipes allow two packages at a
time, each with three compiler jobs. Use one Nix invocation at a time because
the job limit applies per invocation. Earlier builds exhausted memory with
less swap, and an unrooted build was subsequently deleted by garbage collection.
Do not use `--no-link` for these long-lived build results.

The VM smoke test boots a disposable COSMIC session and checks remote-input
capabilities, the panel, and the screen-capture portal. It does not establish
that the physical NVIDIA display or a particular remote client works.

After a successful build, install the new boot generation with the pinned
rebuild tool. `boot` leaves the current desktop session running:

```sh
sudo nix --extra-experimental-features 'nix-command flakes' \
  run .#nixos-rebuild -- boot --flake .#thinkpad
sudo sbctl status
sudo sbctl verify
```

For the complete build, test, and boot-install sequence from a Mac terminal,
run `bash scripts/upgrade-thinkpad-desktop.sh`. The same helper works locally
on the ThinkPad. Both checkouts must already contain the reviewed changes.

The bootloaders and unified images under `/boot/EFI/Linux/` must be signed.
Lanzaboote's detached kernel under `/boot/EFI/nixos/` can appear unsigned.
Save work before rebooting, then log into COSMIC locally.

Check the running portal as the desktop user:

```sh
busctl --user get-property org.freedesktop.portal.Desktop \
  /org/freedesktop/portal/desktop \
  org.freedesktop.portal.RemoteDesktop AvailableDeviceTypes
```

The returned unsigned integer is a bitmask: value 1 represents keyboard and
value 2 represents pointer. Both must be available. Successful introspection alone does not
prove that input is delivered to applications.

## Private RustDesk trial

Use RustDesk as a normal desktop application. The trial does not install
its privileged system service. Without that service, RustDesk can request
remote input through the desktop portal instead of `/dev/uinput`.

The trial uses these settings before the first launch:

1. Set the custom ID server to `127.0.0.1:21116` and relay server to
   `127.0.0.1:21117`. These deliberately unused loopback addresses prevent
   registration with RustDesk's public servers; the ID status will be offline.
2. Enable direct IP access on the ThinkPad, port `21118`, with the IP
   whitelist `127.0.0.1,::1`. Require click approval for incoming sessions.
3. Disable LAN discovery, file transfer, TCP tunneling, clipboard sync, and
   audio for the initial keyboard/display test.
4. Keep the Mac's incoming service disabled. It is the controller.
5. Preserve existing credentials and settings when adapting an existing
   RustDesk installation. Do not commit generated RustDesk configuration,
   passwords, private keys, or portal session tokens.

Do not stop the ThinkPad's RustDesk application service using its internal
`stop-service` option: that also disables its direct IP listener. This is
separate from the privileged operating-system service, which stays absent.

Home Manager merges these settings into RustDesk's writable configuration,
preserving other fields and generated credentials. Quit RustDesk before
applying the configuration, then reopen it so it reads the new settings.
The client package is installed on the ThinkPad; the personal Mac declares
the Homebrew cask. Neither machine enables RustDesk's system daemon.

From the Mac repository, keep this SSH tunnel running in a terminal:

```sh
just connect-thinkpad-desktop
```

In the Mac RustDesk client, connect to `127.0.0.1:21118`. The SSH connection
uses the existing Tailscale host alias and supplies transport encryption.
No additional ThinkPad firewall ports are needed. Approve the connection
and COSMIC's screen/input permission dialog on the ThinkPad.

## Acceptance checks

Before treating this as a supported daily workflow, verify:

1. The Mac displays the ThinkPad desktop, and pointer movement, clicking,
   scrolling, and typing work in a scratch window.
2. Disconnecting and reconnecting works; record whether either permission
   dialog must be approved again.
3. Locking and unlocking works without input reaching the wrong session.
4. Lid closure behaves as intended and the display remains available.
5. After reboot, determine whether a local login is required. A portal for
   sharing the current desktop does not itself provide a remote login server.

The September 7 system build, portal VM test, and post-boot portal checks
passed. The physical RustDesk test failed during capture; see the findings
below. Do not infer unattended or pre-login access from the VM test.

## Physical-machine findings (September 7, 2026)

RustDesk 1.4.5 on the ThinkPad and 1.4.9 on the Mac reached each other over
the private SSH tunnel. The failure is after transport and approval:

1. One successful portal response contained no selected screen. Explicitly
   select the monitor thumbnail before allowing the COSMIC request.
2. A subsequent response contained the 3840×2160 eDP-1 monitor, but PipeWire
   rejected format negotiation with `no more output formats`. The log showed
   COSMIC offering RGBA and RustDesk requesting BGRx/RGBx. RustDesk 1.4.5's
   [capture pipeline](https://github.com/rustdesk/rustdesk/blob/1.4.5/libs/scrap/src/wayland/pipewire.rs)
   links its source directly to those sink formats without `videoconvert`.
3. Later retries produced `Failed to get capturer display info` while the host
   logged duplicate PipeWire initialization. Restarting only the user app
   clears that process state, but is not a proven fix for format negotiation.

A synthetic GStreamer test on this ThinkPad rejects the direct RGBA-to-RGBx
link and succeeds with `videoconvert`. This supports testing a conversion fix;
it does not establish that a patched RustDesk will capture the NVIDIA display.
The installed PipeWire is 1.6.8 and GStreamer is 1.28.6, so the generic message
suggesting a PipeWire upgrade is insufficient diagnosis.

Related upstream evidence includes a
[similar COSMIC format-negotiation report with Sunshine](https://github.com/pop-os/xdg-desktop-portal-cosmic/issues/323)
and [RustDesk reports of capture failure followed by display-info errors](https://github.com/rustdesk/rustdesk/discussions/13378).
The COSMIC developers also
[reported successful RustDesk tests](https://github.com/pop-os/xdg-desktop-portal-cosmic/pull/317),
so this failure does not establish that COSMIC cannot support remote control.

## Simpler VNC alternative: Krfb trial

[Krfb Desktop Sharing](https://apps.kde.org/krfb/) shares the existing session
with standard VNC clients. It is a KDE application, not a requirement to switch
to the Plasma desktop. Its
[PipeWire backend](https://github.com/KDE/krfb/blob/v26.08.0/framebuffers/pipewire/pw_framebuffer.cpp)
uses the ScreenCast and RemoteDesktop portals, and its
[input backend](https://github.com/KDE/krfb/blob/v26.08.0/events/xdp/xdpevents.cpp)
sends keyboard and pointer events through the standard portal methods.
This makes it a reasonable COSMIC trial, not yet a verified replacement.

The optional `thinkpad-vnc-trial` package comes from the existing pinned
unstable input, with a small fix in `pkgs/krfb-cosmic` for the 26.08 listener
regression described below. It does not change the installed system or enable
a service.
From either checkout, with both machines on this revision:

```sh
just prepare-thinkpad-vnc
```

The helper builds or reuses the app, retains a GC root, checks its version without
opening a window, and creates a separate private configuration directory.
It prints the command to launch Krfb when someone is present at the ThinkPad.
It does not start sharing, rebuild NixOS, or require sudo. Existing trial
configuration is preserved; review it if settings were changed during a test.
The profile disables service discovery and enables password-authenticated
unattended access, including when upgrading the earlier trial profile. Generated
passwords are stored only in the private profile, outside the repository and
Nix store, avoiding an extra KWallet setup for this trial.

Keep TCP 5900 closed in the ThinkPad firewall. Stock Krfb binds all interfaces;
its settings do not expose a loopback-only bind option. The SSH tunnel connects
to the host's loopback listener through the already permitted SSH port. Do not
open a VNC firewall port or add an autostart service for this trial.

When someone is present:

1. Run the launch command from the helper in the ThinkPad's COSMIC terminal.
   Select the actual monitor in the portal dialog and choose **Always Allow**
   for screen/input access. Set/save Krfb's separate unattended-access password
   on the Mac during this initial setup.
2. On the Mac run `just connect-thinkpad-vnc`. In Screen Sharing, connect to
   `vnc://127.0.0.1:15900`, using the saved **unattended-access** password.
   The ordinary invitation password follows a different approval path.
3. Test the desktop image, left/right clicks, scrolling, typing, and reconnects.
   Stop the tunnel with Ctrl-C and quit Krfb when finished.

Krfb 26.08.0 initially stayed running without opening a VNC listener. The
normal desktop server never initialized the new `passwordSet` gate, matching
[KDE bug 524610](https://bugs.kde.org/show_bug.cgi?id=524610). The local package
sets that gate from the available credentials while retaining VNC password
authentication. Remove the patch when the pinned release includes the fix.
The package also flushes the portal restore token immediately; otherwise a
service stop can discard the buffered grant and require approval again. The
fresh VM test exercises this without opening or editing Krfb settings.
Only Krfb needs recompilation; the COSMIC packages are reused.

In an isolated COSMIC 1.7 VM, the fixed package delivered the desktop image
(pixel comparison against the VM display passed), remote typing, and left/right
clicks. A wrong password was rejected. COSMIC's saved Always Allow grant was
reused after restarting the app. These results support the design but do not
verify the physical NVIDIA display, Mac Screen Sharing, lock/unlock, or reboot.
No Krfb service or VNC firewall opening was installed on the physical ThinkPad.

Run the repeatable integration check on an x86_64 Linux host with KVM:

```sh
just test-cosmic-vnc
```

It boots a disposable COSMIC session, approves the portal through the VM's
virtual input, checks VNC authentication and framebuffer pixels, then restarts Krfb and tests without approving
again. The VM uses public test credentials and software rendering; neither
is applied to the ThinkPad desktop. Screenshots remain in `result-cosmic-vnc`.
The original portal smoke test remains separately available.

Other options evaluated:

1. **WayVNC:** COSMIC advertises the newer image-copy capture protocol and a
   virtual keyboard, but not `zwlr_virtual_pointer_manager_v1`. The current
   [WayVNC implementation](https://github.com/any1/wayvnc/blob/master/src/main.c)
   requires that pointer protocol unless input is disabled. It is not a complete
   view-and-control replacement on this session.
2. **KRDP:** its [portal backend](https://github.com/KDE/krdp/blob/master/src/PortalSession.cpp)
   is another candidate, but requires an RDP client and TLS configuration.
   Krfb offers a more direct trial with the Mac's existing VNC viewer.
3. **Sunshine/Moonlight:** remains an alternative, but an upstream COSMIC
   capture report shows a similar negotiation failure. Switching applications
   alone does not prove this capture problem is solved.

## Unattended access requirement

The desired workflow is to connect from the trusted Mac without anyone
clicking approval on the ThinkPad. There are two independent permissions:

1. **Krfb connection approval:** its
   [unattended mode](https://docs.kde.org/trunk_kf6/en/krfb/krfb/using-krfb.html)
   authenticates the unattended password without an acceptance dialog.
   The trial helper now enables that mode. Krfb generates passwords on first
   launch; keep them outside Nix and Git and save the unattended password on
   the Mac during initial setup.
2. **COSMIC screen/input permission:** the
   [1.7 dialog](https://github.com/pop-os/xdg-desktop-portal-cosmic/blob/epoch-1.7.0/src/remote_desktop_dialog.rs)
   offers **Always Allow** when the app requests persistent access. Krfb requests
   `persist_mode=2`, saves the returned restore token, and supplies it on its
   next launch. COSMIC's
   [restore path](https://github.com/pop-os/xdg-desktop-portal-cosmic/blob/epoch-1.7.0/src/remote_desktop.rs)
   skips the prompt when the saved devices and capture sources still match.
   Keep Krfb's state file and the portal permission store; a revoked permission
   or changed/missing source can require approval again.

This supports a one-time approval followed by authenticated unattended
connections to an existing desktop. It is not yet an end-to-end result on
this ThinkPad. Test reconnecting, quitting/restarting Krfb, locking/unlocking,
and a reboot before claiming those states work. Once display/input works,
add a graphical-session user service with restart-on-failure for availability.

**Cold boot is a separate requirement.** The current configuration waits for
a local graphical login; Krfb does not provide a login server. A service tied
to the graphical session can start only after that session exists. Do not
silently replace the login policy with automatic login. Automatic login would
create a local desktop without a login password and needs a deliberate policy
decision and testing of any immediate-lock arrangement. A dedicated remote
login desktop or external hardware KVM are other designs if pre-login control
is essential. Neither is implemented by this trial.

The automated check covers capture, authentication, and permission persistence.
Typing and left/right clicks passed the separate interactive COSMIC VM trial.
Launching COSMIC Terminal in the fresh test was unreliable, so GUI input remains
a manual acceptance check rather than a claimed automated result.
