{ unstablePkgs, ... }:
{
  home.packages = with unstablePkgs; [
    caffeine
    thaw
  ];
}
