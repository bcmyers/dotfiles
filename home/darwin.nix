{ unstablePkgs, ... }:
{
  launchd.agents = {
    caffeine = {
      enable = true;
      config = {
        ProcessType = "Interactive";
        ProgramArguments = [
          "${unstablePkgs.caffeine}/Applications/Caffeine.app/Contents/MacOS/Caffeine"
        ];
        RunAtLoad = true;
      };
    };

    ice = {
      enable = true;
      config = {
        ProcessType = "Interactive";
        ProgramArguments = [
          "${unstablePkgs.ice-bar}/Applications/Ice.app/Contents/MacOS/Ice"
        ];
        RunAtLoad = true;
      };
    };
  };
}
