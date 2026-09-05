{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # Pass credentials to one explicit command, not every shell and descendant.
  withSecrets =
    name: bindings:
    pkgs.writeShellApplication {
      inherit name;
      text = ''
        if (( $# == 0 )); then
          echo "Usage: ${name} COMMAND [ARG...]" >&2
          exit 2
        fi
      ''
      + lib.concatStringsSep "\n" (
        lib.mapAttrsToList (variable: secret: ''
          if [[ ! -r ${lib.escapeShellArg config.sops.secrets.${secret}.path} ]]; then
            echo "${name}: ${secret} is unavailable; check sops-nix." >&2
            exit 1
          fi
          secret_value="$(< ${lib.escapeShellArg config.sops.secrets.${secret}.path})"
          if [[ -z "$secret_value" ]]; then
            echo "${name}: ${secret} is empty." >&2
            exit 1
          fi
          export ${variable}="$secret_value"
          unset secret_value
        '') bindings
      )
      + ''
        exec "$@"
      '';
    };
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  home.packages = [
    (withSecrets "with-anthropic" { ANTHROPIC_API_KEY = "anthropic_api_key"; })
    (withSecrets "with-twilio" {
      TWILIO_SID = "twilio_sid";
      TWILIO_CLIENT_SECRET = "twilio_client_secret";
    })
  ];

  sops = {
    age.keyFile =
      if pkgs.stdenv.hostPlatform.isDarwin then
        "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt"
      else
        "${config.xdg.configHome}/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/personal.yaml;
    defaultSopsFormat = "yaml";
    secrets = {
      anthropic_api_key = { };
      twilio_client_secret = { };
      twilio_sid = { };
    };
  };
}
