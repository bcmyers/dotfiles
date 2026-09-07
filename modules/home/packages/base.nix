{
  pkgs,
  promptPackage,
  ...
}:
{
  home.packages =
    (with pkgs; [
      btop
      bzip2
      coreutils
      curl
      diffutils
      fd
      gh
      htop
      hyperfine
      jq
      just
      moreutils
      openssl
      pandoc
      qrencode
      ripgrep
      rsync
      tree
      unzip
      wget
      xz
      yq-go
      zip
    ])
    ++ [ promptPackage ];
}
