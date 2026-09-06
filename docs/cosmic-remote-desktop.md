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
./scripts/nix-flake.sh build \
  .#nixosConfigurations.thinkpad.config.system.build.toplevel \
  .#checks.x86_64-linux.cosmic-remote-desktop \
  --no-link --cores 3 --max-jobs 2
```

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

As of the initial configuration change, the physical-machine client tests
are pending. Do not infer unattended or pre-login access from the VM test.
