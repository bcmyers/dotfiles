{
  networking = {
    hostName = "thinkpad";
    networkmanager.enable = true;
    firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ ];
    };
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
