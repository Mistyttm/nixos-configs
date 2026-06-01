{ ... }:
{
  flake.homeModules.misty =
    { lib, ... }:
    {
      home.username = lib.mkDefault "misty";
      home.homeDirectory = lib.mkDefault "/home/misty";
    };
}
