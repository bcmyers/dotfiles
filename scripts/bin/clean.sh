#!/usr/bin/env bash

set -eux

find ~/robinhood -name Cargo.toml -type f -execdir cargo clean \;
