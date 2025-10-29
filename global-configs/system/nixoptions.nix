{ config, ... }:

{
  sops.secrets."access-tokens" = {
    sopsFile = ../../secrets/github.yaml;
    owner = "root";
  };

  nix = {
    settings = {
      cores = 6;
      auto-optimise-store = true;
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [
        "misty"
      ];
    };
    optimise = {
      automatic = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # extraOptions = ''
    #   include ${config.sops.secrets."access-tokens".path}
    # '';
  };

  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "10G";
    MemoryMax = "15G";
  };
}
