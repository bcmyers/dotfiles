default: check

build-thinkpad:
    ./scripts/nix-flake.sh build '.#nixosConfigurations.thinkpad.config.system.build.toplevel'

build-work-mac:
    ./scripts/nix-flake.sh build '.#homeConfigurations."brian.myers@work-mac".activationPackage'

build-work-devbox:
    ./scripts/nix-flake.sh build '.#homeConfigurations."root@work-devbox".activationPackage'

build-personal-mac:
    ./scripts/nix-flake.sh build '.#darwinConfigurations.personal-mac.system'

build-vm:
    ./scripts/nix-flake.sh build '.#vm' --out-link result-vm

test-disko:
    ./scripts/nix-flake.sh build '.#disko-test' --print-build-logs

check:
    ./scripts/nix-flake.sh flake check --all-systems --no-build --print-build-logs

edit-secrets:
    ./scripts/nix-flake.sh run .#sops -- secrets/personal.yaml

format:
    ./scripts/nix-flake.sh fmt

show:
    ./scripts/nix-flake.sh flake show --all-systems

switch-thinkpad:
    ./scripts/switch-thinkpad.sh

switch-personal-mac:
    ./scripts/switch-personal-mac.sh

switch-work-mac:
    ./scripts/switch-work-mac.sh

switch-work-devbox:
    ./scripts/switch-work-devbox.sh

rust-update:
    rustup update stable
    rustup default stable
    rustup component add clippy rust-analyzer rustfmt

vm: build-vm
    ./result-vm/bin/run-thinkpad-vm-vm

update:
    ./scripts/nix-flake.sh flake update
