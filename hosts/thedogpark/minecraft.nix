{ config, pkgs, nix-minecraft, ... }: {
    imports = [
        nix-minecraft.nixosModules.minecraft-servers
    ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
#       servers.skyship = {
#
#       };
    };
}
