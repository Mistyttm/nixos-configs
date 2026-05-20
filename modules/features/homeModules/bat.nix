{ ... }:
{
  flake.homeModules.bat =
    { pkgs, ... }:
    {
      programs.bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [ core ];
      };
    };
}
