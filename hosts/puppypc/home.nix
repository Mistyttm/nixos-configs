{ pkgs, config, ... }:
{
  imports = [
    ../../global-configs/home-base.nix
    ../../global-configs/shell/default.nix
    ../../global-configs/programs/default.nix
    ./configs/programs/default.nix
    ./configs/gnupg/gnupg.nix
  ];

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .#puppypc";
    upgrade = "/home/misty/Documents/nixos-configs-main && nix flake update && sudo nixos-rebuild switch --flake .#puppypc";
  };

  systemd.user.services.steam-presence = {
    Service = {
      ExecStart = "${pkgs.steam-presence}/bin/steam-presence";
      Type = "simple";
      Nice = 19;
      SuccessExitStatus = "130";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ReadWritePaths = "${config.xdg.configHome}/steam-presence";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
