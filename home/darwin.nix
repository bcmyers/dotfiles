{
  config,
  lib,
  unstablePkgs,
  ...
}:
let
  secretPath = name: config.sops.secrets.${name}.path;
in
{
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

  programs.password-store = {
    enable = true;
    package = unstablePkgs.pass.withExtensions (extensions: [ extensions.pass-otp ]);
  };

  services.ollama = {
    enable = true;
    package = unstablePkgs.ollama;
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt";
    defaultSopsFile = ../secrets/mac.yaml;
    defaultSopsFormat = "yaml";
    secrets = {
      anthropic_api_key = { };
      twilio_client_secret = { };
      twilio_sid = { };
    };
  };
}
