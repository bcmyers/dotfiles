{ unstablePkgs, ... }:
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
    "nvim/nvim-pack-lock.json".source = ../../../files/nvim/nvim-pack-lock.json;
  };
}
