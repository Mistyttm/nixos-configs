{ ... }:

{
  sops.secrets."access-tokens" = {
    sopsFile = ../../secrets/github.yaml;
    owner = "root";
  };

  nix = {
    settings = {
      cores = 2; # Further reduced to 2 for stability with PBO+EXPO during large builds
      max-jobs = 1; # Single package at a time to prevent memory pressure
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
    # GitHub token for higher API rate limits
    # Can't use include here due to build-time validation
    # Instead, configure via netrc or use manual token
    # extraOptions = ''
    #   !include ${config.sops.secrets."access-tokens".path}
    # '';
  };

  # Increased memory limits for nix-daemon to prevent OOM during large builds
  # With 32GB RAM, these limits were too restrictive and caused system reboots
  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "20G"; # Increased from 10G - throttling threshold
    MemoryMax = "28G"; # Increased from 15G - hard limit (leave 4GB for system)
  };
}
