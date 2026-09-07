{ pkgs, unstablePkgs, ... }:
{
  # Install at the system level so Codex is available even before the first
  # Home Manager activation can decrypt the user's SOPS secrets.
  environment.systemPackages = [
    unstablePkgs.codex
    # Make the Linux sandbox helper available on a fresh installation.
    pkgs.bubblewrap
  ];

  # System defaults leave ~/.codex/config.toml writable for interactive
  # preferences, project trust, and MCP configuration. Credentials stay local.
  environment.etc."codex/config.toml".source = (pkgs.formats.toml { }).generate "codex-config.toml" {
    model = "gpt-6-astra";
    model_reasoning_effort = "xhigh";
    check_for_update_on_startup = false;
  };
}
