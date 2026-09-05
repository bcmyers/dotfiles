{ lib, pkgs, ... }:
{
  programs.firefox.enable = true;
  environment.systemPackages = [ pkgs.google-chrome ];

  # This laptop needs the proprietary Pascal driver and the user's Chrome.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
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
