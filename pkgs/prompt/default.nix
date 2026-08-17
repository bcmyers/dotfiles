{
  cmake,
  lib,
  openssl,
  pkg-config,
  rustPlatform,
  src,
  zlib,
}:
rustPlatform.buildRustPackage {
  pname = "prompt";
  version = "0.1.0";

  inherit src;
  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openssl
    zlib
  ];

  meta = {
    description = "Brian Myers' custom shell prompt";
    homepage = "https://github.com/bcmyers/prompt";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "prompt";
    platforms = lib.platforms.unix;
  };
}
