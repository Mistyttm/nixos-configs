{...}: {
  flake.nixosModules.misty = {pkgs, ...}: {
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

  flake.homeModules.misty = {lib, ...}: {
    home.username = lib.mkDefault "misty";
    home.homeDirectory = lib.mkDefault "/home/misty";
  };
}
