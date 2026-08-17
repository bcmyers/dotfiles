{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      core = {
        editor = "nvim";
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
    };
  };
}
