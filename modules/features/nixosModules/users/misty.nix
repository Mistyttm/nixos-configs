{ ... }:
{
  flake.nixosModules.misty =
    { pkgs, ... }:
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
