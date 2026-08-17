{
  homeDirectory,
  inputs,
  isDarwin,
  unstablePkgs,
  ...
}:
{
  home-manager = {
    backupFileExtension = "home-manager-backup";
    extraSpecialArgs = {
      inherit
        homeDirectory
        inputs
        isDarwin
        unstablePkgs
        ;
      isSystemManaged = true;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.bcmyers = import ../home;
  };
}
