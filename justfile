default: check

build:
    ./nix-flake.sh build '.#nixosConfigurations.thinkpad.config.system.build.toplevel'

build-home: build-home-linux

build-home-linux:
    ./nix-flake.sh build '.#homeConfigurations."bcmyers@linux".activationPackage'

build-home-mac:
    ./nix-flake.sh build '.#homeConfigurations."bcmyers@mac".activationPackage'

build-mac:
    ./nix-flake.sh build '.#darwinConfigurations.mac.system'

build-vm:
    ./nix-flake.sh build '.#vm' --out-link result-vm

test-disko:
    ./nix-flake.sh build '.#disko-test' --print-build-logs

check:
    ./nix-flake.sh flake check --all-systems --no-build --print-build-logs

format:
    ./nix-flake.sh fmt

show:
    ./nix-flake.sh flake show --all-systems

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
    ./nix-flake.sh flake update
