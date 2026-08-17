default: check

build:
    ./scripts/nix-flake.sh build '.#nixosConfigurations.thinkpad.config.system.build.toplevel'

build-home: build-home-linux

build-home-linux:
    ./scripts/nix-flake.sh build '.#homeConfigurations."bcmyers@linux".activationPackage'

build-home-mac:
    ./scripts/nix-flake.sh build '.#homeConfigurations."bcmyers@mac".activationPackage'

build-mac:
    ./scripts/nix-flake.sh build '.#darwinConfigurations.mac.system'

build-vm:
    ./scripts/nix-flake.sh build '.#vm' --out-link result-vm

test-disko:
    ./scripts/nix-flake.sh build '.#disko-test' --print-build-logs

check:
    ./scripts/nix-flake.sh flake check --all-systems --no-build --print-build-logs

edit-secrets:
    ./scripts/nix-flake.sh run .#sops -- secrets/shared.yaml

format:
    ./scripts/nix-flake.sh fmt

show:
    ./scripts/nix-flake.sh flake show --all-systems

switch:
    ./scripts/switch-linux.sh

switch-mac:
    ./scripts/switch-mac.sh

rust-update:
    rustup update stable
    rustup default stable
    rustup component add clippy rust-analyzer rustfmt

vm: build-vm
    ./result-vm/bin/run-thinkpad-vm-vm

update:
    ./scripts/nix-flake.sh flake update
