{
  imports = [
    ./core.nix
    ./packages/base.nix
    ./platform
    ./programs/editor.nix
    ./programs/git.nix
    ./programs/shell.nix
    ./programs/terminal.nix
  ];

  programs.home-manager.enable = true;
}
