{
  config,
  inputs,
  isDarwin,
  lib,
  ...
}:
let
  secretPath = name: config.sops.secrets.${name}.path;
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  programs.fish.interactiveShellInit = lib.mkAfter ''
    if test -r "${secretPath "anthropic_api_key"}"
      set -gx ANTHROPIC_API_KEY (string collect < "${secretPath "anthropic_api_key"}")
    end
    if test -r "${secretPath "twilio_sid"}"
      set -gx TWILIO_SID (string collect < "${secretPath "twilio_sid"}")
    end
    if test -r "${secretPath "twilio_client_secret"}"
      set -gx TWILIO_CLIENT_SECRET (string collect < "${secretPath "twilio_client_secret"}")
    end
  '';

  sops = {
    age.keyFile =
      if isDarwin then
        "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt"
      else
        "${config.xdg.configHome}/sops/age/keys.txt";
    defaultSopsFile = ../secrets/shared.yaml;
    defaultSopsFormat = "yaml";
    secrets = {
      anthropic_api_key = { };
      twilio_client_secret = { };
      twilio_sid = { };
    };
  };
}
