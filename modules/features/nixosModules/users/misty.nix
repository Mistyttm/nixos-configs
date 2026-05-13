{ config, ... }:
let
  hostName = config.networking.hostName or "";
in
{
  flake.nixosModules.misty =
    { lib, pkgs, ... }:
    {
      users.users.misty = {
        isNormalUser = true;
        description = "Emmey Leo";
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "libvirt"
          "input"
          "scanner"
          "lp"
          "gamemode"
        ];
        shell = pkgs.zsh;
      };

      programs.zsh.enable = true;
    };
}
