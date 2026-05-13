{ inputs, ... }:
{
  flake.nixosModules.ssh =
    { pkgs, lib, ... }:
    {
      services.openssh.enable = true;
    };
}
