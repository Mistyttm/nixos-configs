{ homeVersion, pkgs, config, ... }:
{
  home.username = "misty";
  home.homeDirectory = "/home/misty";

  imports = [
    ../../global-configs/shell/default.nix
    ../../global-configs/programs/default.nix
    ./configs/programs/default.nix
    ./configs/gnupg/gnupg.nix
  ];

  home.stateVersion = homeVersion;

  home.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake .#puppypc";
    upgrade = "/home/misty/Documents/nixos-configs-main && nix flake update && sudo nixos-rebuild switch --flake .#puppypc";
  };

  programs.home-manager.enable = true;

  systemd.user.services.steam-presence = {
#       description = ["Discord rich presence from Steam on Linux"];

      Service = {
        # Adjust this path if you’ve packaged it in Nix instead of cloning.
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

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
