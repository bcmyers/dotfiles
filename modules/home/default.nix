{
  imports = [
    ./core.nix
    ./packages.nix
    ./platform
    ./programs/editor.nix
    ./programs/git.nix
    ./programs/security.nix
    ./programs/shell.nix
    ./programs/terminal.nix
  ];

  programs.home-manager.enable = true;
}
