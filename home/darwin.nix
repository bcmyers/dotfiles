{
  unstablePkgs,
  ...
}:
{
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
}
