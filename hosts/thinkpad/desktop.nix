{ lib, pkgs, ... }:
{
  programs.firefox.enable = true;
  environment.systemPackages = [ pkgs.google-chrome ];

  # Explicit proprietary applications requested for this laptop.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "chatgpt"
      "google-chrome"
      "nvidia-kernel-modules"
      "nvidia-settings"
      "nvidia-x11"
    ];

  security = {
    polkit.enable = true;
    rtkit.enable = true;
    sudo.wheelNeedsPassword = true;
  };

  services = {
    # Apply Caps Lock as Control before COSMIC or a console handles the key.
    # This also covers the login screen and attached physical keyboards.
    keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings.main.capslock = "layer(control)";
      };
    };

    # Home Manager owns the OpenSSH agent. Keep GNOME Keyring for desktop
    # credentials without starting a competing SSH agent in COSMIC.
    gnome.gcr-ssh-agent.enable = false;
    desktopManager.cosmic.enable = true;
    displayManager.cosmic-greeter.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    power-profiles-daemon.enable = true;
    printing.enable = true;
    thermald.enable = true;
    upower.enable = true;
    xserver = {
      videoDrivers = [ "nvidia" ];
      xkb.layout = "us";
    };
  };
}
