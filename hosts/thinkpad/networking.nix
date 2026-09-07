{
  networking = {
    hostName = "thinkpad";
    networkmanager.enable = true;
    firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    tailscale.enable = true;
  };
}
