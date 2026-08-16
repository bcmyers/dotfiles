default: check

build:
    nix --extra-experimental-features "nix-command flakes" build '.#homeConfigurations."bcmyers@linux".activationPackage'

check:
    nix --extra-experimental-features "nix-command flakes" flake check --all-systems --no-build --print-build-logs

format:
    nix --extra-experimental-features "nix-command flakes" fmt

gc:
    ./nix-garbage-collections.sh

switch:
    ./nix-switch.sh

update:
    nix --extra-experimental-features "nix-command flakes" flake update
