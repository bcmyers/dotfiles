{
  lib,
  pkgs,
  ...
}:
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  programs.fish.shellInit = lib.mkAfter ''
    # Keep Homebrew as a deduplicated, lowest-priority macOS fallback even
    # when Terminal inherited the old Homebrew-first environment.
    set -l path_without_homebrew
    for path_entry in $PATH
      if not contains -- $path_entry /opt/homebrew/bin /opt/homebrew/sbin
        if not contains -- $path_entry $path_without_homebrew
          set --append path_without_homebrew $path_entry
        end
      end
    end
    set --global --export PATH $path_without_homebrew /opt/homebrew/bin /opt/homebrew/sbin
  '';
}
