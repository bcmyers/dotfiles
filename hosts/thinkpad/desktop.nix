{
  security = {
    polkit.enable = true;
    rtkit.enable = true;
    sudo.wheelNeedsPassword = true;
  };

  services = {
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
