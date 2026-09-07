{
  config,
  lib,
  pkgs,
  unstablePkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    initLua = builtins.readFile ../../../files/nvim/init.lua;
    package = unstablePkgs.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
  };

  xdg.configFile = {
    "nvim/after".source = ../../../files/nvim/after;
  };

  # vim.pack rewrites its lockfile when synchronizing cached plugin checkouts.
  # Seed a writable copy of the tracked pins instead of a Nix-store symlink.
  home.activation.nvimLockfile = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${pkgs.coreutils}/bin/install -Dm644 \
      ${../../../files/nvim/nvim-pack-lock.json} \
      ${lib.escapeShellArg "${config.xdg.configHome}/nvim/nvim-pack-lock.json"}
  '';
}
