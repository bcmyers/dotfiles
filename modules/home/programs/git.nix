{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    signing = {
      format = "openpgp";
      key = "B86678B99457460F";
      signByDefault = true;
    };
    settings = {
      core = {
        editor = "nvim";
        fsmonitor = true;
        untrackedCache = true;
      };
      diff.algorithm = "patience";
      fetch.prune = true;
      init.defaultBranch = "main";
      merge = {
        conflictStyle = "zdiff3";
        tool = "nvimdiff";
      };
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        default = "simple";
      };
      rebase.autoStash = true;
      user = {
        email = "brian.carl.myers@gmail.com";
        name = "Brian Myers";
      };
    };
  };
}
