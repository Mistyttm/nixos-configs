{
  config,
  ...
}:
{
  sops.secrets.github_token = {
    sopsFile = ../../secrets/github.yaml;
    # no `path` override needed, defaults to /run/secrets/github_token
  };

  # Use the template feature to render the netrc file with the secret interpolated
  sops.templates."nix-netrc" = {
    path = "/etc/nix/netrc";
    owner = "root";
    group = "root";
    mode = "0600";
    content = ''
      machine github.com
      login token
      password ${config.sops.placeholder.github_token}
    '';
  };

  sops.templates."nix-access-tokens" = {
    path = "/etc/nix/access-tokens.conf";
    owner = "root";
    mode = "0600";
    content = ''
      access-tokens = github.com=${config.sops.placeholder.github_token}
    '';
  };

  nix = {
    settings = {
      cores = 2;
      max-jobs = 1;
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
      !include /etc/nix/access-tokens.conf
    '';
  };

  systemd.services.nix-daemon.serviceConfig = {
    MemoryHigh = "20G";
    MemoryMax = "28G";
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = builtins.toString ../..;
  };
}
