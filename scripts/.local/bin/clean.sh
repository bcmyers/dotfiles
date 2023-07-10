#!/usr/bin/env bash

set -eux

(cd ~/robinhood/rh && bazel clean --expunge)
(cd ~/robinhood/rh1 && bazel clean --expunge)
(cd ~/robinhood/rh2 && bazel clean --expunge)
(cd ~/robinhood/rh3 && bazel clean --expunge)
(cd ~/robinhood/rh4 && bazel clean --expunge)
rm -rf ~/.cache/bazel-disk-cache

# find ~/lib -name Cargo.toml -type f -execdir cargo clean \;
find ~/opt -name Cargo.toml -type f -execdir cargo clean \;
find ~/robinhood -name Cargo.toml -type f -execdir cargo clean \;
