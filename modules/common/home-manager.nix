{
  homeDirectory,
  inputs,
  promptPackage,
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
        promptPackage
        unstablePkgs
        ;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.bcmyers = import ../../users/bcmyers;
  };
}
