{ pkgs, ... }:
{
  home.sessionVariables.AWS_DEFAULT_PROFILE = "brian.myers";

  programs.awscli = {
    enable = true;
    package = pkgs.awscli2;
    settings."profile brian.myers".region = "us-east-1";
  };
}
