{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libsecret,
  libusb1,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  pango,
  systemd,
  vulkan-loader,
  wayland,
  xdg-utils,
  git,
  version ? "26.901.51231",
  sha256 ? "62580188d87c3d3a9369dab7c73b42a8a32518d4df8a2d5bae6466ddeac5c05e",
}:
stdenvNoCC.mkDerivation {
  pname = "chatgpt";
  inherit version;

  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${version}_amd64.deb";
    inherit sha256;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];
  buildInputs = [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libgbm
    libglvnd
    libnotify
    libsecret
    libusb1
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    vulkan-loader
    wayland
  ];
  runtimeDependencies = [
    libglvnd
    libsecret
    libnotify
    systemd
    vulkan-loader
    wayland
  ];
  dontWrapGApps = true;
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --extract "$src" source
    runHook postUnpack
  '';
  sourceRoot = "source";
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib" "$out/bin" "$out/share" "$out/nix-support"
    cp -a usr/lib/chatgpt "$out/lib/"
    # COSMIC uses the GTK integration; the optional Qt theme shims are unused.
    rm -f "$out/lib/chatgpt/libqt5_shim.so" "$out/lib/chatgpt/libqt6_shim.so"
    # NixOS uses glibc. Exclude bundled Alpine/musl addon alternatives from ELF patching.
    find "$out/lib/chatgpt" -type f -name '*.node' -path '*musl*' -delete
    cp -a usr/share/applications usr/share/pixmaps usr/share/doc "$out/share/"
    cat > "$out/nix-support/upstream.json" <<'JSON'
    ${builtins.toJSON { inherit version sha256; }}
    JSON
    runHook postInstall
  '';
  preFixup = ''
    makeWrapper "$out/lib/chatgpt/codex-launcher" "$out/bin/chatgpt" \
      --prefix PATH : ${
        lib.makeBinPath [
          git
          xdg-utils
        ]
      } \
      --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = {
    description = "Official ChatGPT Linux desktop preview";
    homepage = "https://learn.chatgpt.com/docs/linux/linux-app";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "chatgpt";
  };
}
