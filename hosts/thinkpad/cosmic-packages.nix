{ inputs, ... }:
{
  # Keep the COSMIC suite and its internal dependencies on one package set.
  # Remove this overlay when the primary nixpkgs input provides COSMIC >= 1.7.
  nixpkgs.overlays = [
    (
      _final: prev:
      let
        cosmic = import inputs.nixpkgs-cosmic {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = false;
        };
        names = [
          "cosmic-applets"
          "cosmic-app-library"
          "cosmic-bg"
          "cosmic-comp"
          "cosmic-edit"
          "cosmic-files"
          "cosmic-greeter"
          "cosmic-icons"
          "cosmic-idle"
          "cosmic-initial-setup"
          "cosmic-launcher"
          "cosmic-monitor"
          "cosmic-notifications"
          "cosmic-osd"
          "cosmic-panel"
          "cosmic-player"
          "cosmic-randr"
          "cosmic-reader"
          "cosmic-screenshot"
          "cosmic-session"
          "cosmic-settings"
          "cosmic-settings-daemon"
          "cosmic-sound-theme"
          "cosmic-store"
          "cosmic-term"
          "cosmic-wallpapers"
          "cosmic-workspaces-epoch"
          "xdg-desktop-portal-cosmic"
        ];
      in
      prev.lib.genAttrs names (name: cosmic.${name})
      // {
        # The stable NixOS desktop module uses the name from before the rename.
        cosmic-applibrary = cosmic.cosmic-app-library;
      }
    )
  ];
}
