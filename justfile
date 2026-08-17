default: check

build:
    nix build '.#nixosConfigurations.thinkpad.config.system.build.toplevel'

build-home: build-home-linux

build-home-linux:
    nix build '.#homeConfigurations."bcmyers@linux".activationPackage'

build-home-mac:
    nix build '.#homeConfigurations."bcmyers@mac".activationPackage'

build-mac:
    nix build '.#darwinConfigurations.mac.system'

build-vm:
    nix build '.#vm' --out-link result-vm

test-disko:
    nix build '.#disko-test' --print-build-logs

check:
    nix flake check --all-systems --no-build --print-build-logs

format:
    nix fmt

gc:
    ./nix-garbage-collections.sh

switch:
    ./nix-switch.sh

switch-mac:
    ./nix-switch-mac.sh

rust-update:
    rustup update stable
    rustup default stable
    rustup component add clippy rust-analyzer rustfmt

vm: build-vm
    ./result-vm/bin/run-thinkpad-vm-vm

update:
    nix flake update
