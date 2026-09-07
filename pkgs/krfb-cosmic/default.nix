{ kdePackages }:
kdePackages.krfb.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./start-authenticated-server.patch
    ./save-portal-token.patch
  ];
})
