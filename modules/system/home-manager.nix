{
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
        inputs
        promptPackage
        unstablePkgs
        ;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
