{ pkgs, unstablePkgs, ... }:
{
  home.packages =
    # Mature build tools follow the host's primary package set.
    (with pkgs; [
      autoconf
      automake
      bazel-buildtools
      bazelisk
      clang-tools
      gcc
      gettext
      gnumake
      graphviz
      luarocks
      ninja
      patchutils
      pkg-config
      shellcheck
      shfmt
      tree-sitter
      yarn
    ])
    # Fast-moving language toolchains and developer tools follow unstable.
    ++ (with unstablePkgs; [
      cargo-update
      cmake
      go
      gotools
      gopls
      jujutsu
      lua-language-server
      nixd
      nixfmt
      nodejs_26
      pi-coding-agent
      prettier
      python3
      rustup
      sqlx-cli
      starpls
      stylua
      trunk
      typescript-language-server
      uv
    ]);
}
