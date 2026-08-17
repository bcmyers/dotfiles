{ lib, ... }:
{
  # Windsurf is a personal opt-in because it sends editor context to a hosted
  # service. It is deliberately absent from the work profile.
  programs.neovim.initLua = lib.mkAfter (builtins.readFile ../../files/nvim/windsurf.lua);
}
