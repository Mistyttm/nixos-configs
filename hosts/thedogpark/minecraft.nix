{ config, pkgs, nix-minecraft, inputs, ... }: {

    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
#       servers.skyship = {
#
#       };
    };
}
