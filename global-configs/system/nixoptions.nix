{ config, ... }:

{
  sops.secrets."access-tokens" = {
    sopsFile = ../../secrets/github.yaml;
    owner = "root";
    mode = "0400";
  };

  nix = {
    settings = {
      cores = 2; # Further reduced to 2 for stability with PBO+EXPO during large builds
      max-jobs = 1; # Single package at a time to prevent memory pressure
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
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
    extraOptions = ''
      netrc-file = /etc/nix/netrc
    '';
  };

  # Write the netrc file at activation using the decrypted sops secret
  system.activationScripts.nix-github-netrc = {
    deps = [ "setupSecrets" ];
    text = ''
      raw=$(cat ${config.sops.secrets."access-tokens".path})
      token="''${raw#github.com=}"
      install -m 600 -o root /dev/null /etc/nix/netrc
      echo "machine api.github.com login x-access-token password $token" > /etc/nix/netrc
      echo "machine github.com login x-access-token password $token" >> /etc/nix/netrc
    '';
  };

  # Increased memory limits for nix-daemon to prevent OOM during large builds
  # With 32GB RAM, these limits were too restrictive and caused system reboots
  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "20G"; # Increased from 10G - throttling threshold
    MemoryMax = "28G"; # Increased from 15G - hard limit (leave 4GB for system)
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = builtins.toString ../..; # evaluate flake root at build time
  };
}
