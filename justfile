default: check

build-thinkpad:
    ./scripts/nix-flake.sh build '.#nixosConfigurations.thinkpad.config.system.build.toplevel'

build-work-mac:
    ./scripts/nix-flake.sh build '.#homeConfigurations."brian.myers@work-mac".activationPackage'

build-work-devbox:
    ./scripts/build-work-devbox.sh

build-personal-mac:
    ./scripts/nix-flake.sh build '.#darwinConfigurations.personal-mac.system'

build-vm:
    ./scripts/nix-flake.sh build '.#vm' --out-link result-vm

test-disko:
    ./scripts/nix-flake.sh build '.#disko-test' --print-build-logs

test-thinkpad-boot:
    ./scripts/nix-flake.sh build '.#thinkpad-boot-test' --print-build-logs

test-cosmic-remote-desktop:
    ./scripts/nix-flake.sh build '.#checks.x86_64-linux.cosmic-remote-desktop' --print-build-logs

connect-thinkpad-desktop:
    bash ./scripts/connect-thinkpad-desktop.sh

check: check-secrets
    ./scripts/nix-flake.sh flake check --all-systems --no-build --print-build-logs

check-secrets:
    ./scripts/check-secrets.sh

test-nvim:
    bash ./scripts/check-nvim.sh

test-chatgpt-updater:
    python3 ./tests/chatgpt-updater.py

restore-thinkpad-gpg:
    bash ./scripts/restore-thinkpad-gpg.sh

install-hooks:
    ./scripts/install-git-hooks.sh

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

upgrade-homebrew-casks:
    brew update
    brew upgrade --cask

vm: build-vm
    ./result-vm/bin/run-thinkpad-vm-vm

update:
    ./scripts/nix-flake.sh flake update
