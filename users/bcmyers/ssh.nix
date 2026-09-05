{
  config,
  lib,
  pkgs,
  ...
}:
let
  isMac = pkgs.stdenv.hostPlatform.isDarwin;
  deviceKey = if isMac then "~/.ssh/id_ed25519" else "~/.ssh/id_ed25519_thinkpad";
  tailnet = "bilby-allosaurus.ts.net";
  tailnetUsers = {
    bcmyers = "bcmyers";
    jamyers = "jamyers";
    macbook = "bcmyers";
    raspberrypi-kc = "bcmyers";
    thinkpad = "bcmyers";
  };
  deviceIdentity = {
    IdentityFile = deviceKey;
    # Keep the Mac's existing GPG-agent fallback until each destination has
    # been tested with its own Ed25519 key. Fresh Linux installs use one key.
    IdentitiesOnly = !isMac;
  };
in
{
  programs.ssh = {
    enable = true;
    # Preserve Apple's SSH client on the Mac; Linux uses the pinned client.
    package = if isMac then null else pkgs.openssh;
    enableDefaultConfig = false;
    settings =
      lib.mapAttrs' (
        name: user:
        lib.nameValuePair "${name} ${name}.${tailnet}" (
          deviceIdentity
          // {
            HostName = "${name}.${tailnet}";
            User = user;
            # Use the canonical hostname for host-key verification. Short
            # aliases and the FQDN must identify the same server.
            HostKeyAlias = "${name}.${tailnet}";
          }
        )
      ) tailnetUsers
      // {
        "github.com" = deviceIdentity // {
          HostName = "github.com";
          User = "git";
          # The Mac's device key was independently tested against GitHub.
          IdentitiesOnly = true;
          StrictHostKeyChecking = "yes";
          UserKnownHostsFile = "~/.ssh/known_hosts ${config.home.homeDirectory}/.ssh/known_hosts.d/github";
        };
        "bcmyers.com" = deviceIdentity // {
          HostName = "bcmyers.com";
          User = "bcmyers";
        };
        "*" = {
          ForwardAgent = false;
          # Do not import the Mac's device key into the transitional GPG agent.
          AddKeysToAgent = if isMac then "no" else "2h";
        }
        // lib.optionalAttrs (!isMac) {
          # GUI applications and shells must use the same managed agent.
          IdentityAgent = "\${XDG_RUNTIME_DIR}/ssh-agent";
        };
      };
  };

  home.file.".ssh/known_hosts.d/github".source = ../../files/ssh/github-known-hosts;

  services.ssh-agent = lib.mkIf (!isMac) {
    enable = true;
    defaultMaximumIdentityLifetime = 7200;
  };
}
