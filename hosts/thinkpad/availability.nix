{
  # Keep the laptop reachable with the lid closed, including on battery during
  # an outage. The battery policy powers it off cleanly before exhaustion.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    IdleAction = "ignore";
  };

  # Also covers sleep requests from the desktop, which can override logind.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
  };

  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageLow = 20;
    percentageCritical = 10;
    percentageAction = 5;
    criticalPowerAction = "PowerOff";
  };
  systemd.services.upower.wantedBy = [ "multi-user.target" ];

  # Start the user's service manager before login, including the SSH agent
  # and SOPS services. This does not log in to COSMIC or start a Codex job.
  users.users.bcmyers.linger = true;
}
