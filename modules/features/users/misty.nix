{
  self,
  lib,
  ...
}: let
  # One public key per machine misty logs in from: ssh-keys/<hostname>.pub.
  # Every host authorizes all of them.
  sshKeyDir = ./ssh-keys;
  sshKeyFiles = lib.optionals (builtins.pathExists sshKeyDir) (
    map (name: sshKeyDir + "/${name}") (
      builtins.filter (lib.hasSuffix ".pub") (builtins.attrNames (builtins.readDir sshKeyDir))
    )
  );
in {
  flake.nixosModules.misty = {
    config,
    pkgs,
    ...
  }: let
    # This host's own private key, from secrets/ssh-<hostname>.yaml
    # (encrypted to this host only; see .sops.yaml).
    sshKeySecret = "ssh-${config.networking.hostName}";
    hasSshKey = self.secrets ? ${sshKeySecret};
  in {
    sops.secrets.misty-ssh-key = lib.mkIf hasSshKey {
      sopsFile = self.secrets.${sshKeySecret};
      key = "ssh_key";
      owner = "misty";
      mode = "0400";
    };

    # Kept in /run/secrets rather than ~/.ssh so sops-nix never creates a
    # root-owned ~/.ssh on a fresh host.
    programs.ssh.extraConfig = lib.mkIf hasSshKey ''
      Match localuser misty
        IdentityFile ${config.sops.secrets.misty-ssh-key.path}
      Match all
    '';

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
      openssh.authorizedKeys.keyFiles = sshKeyFiles;
    };

    programs.zsh.enable = true;
  };

  flake.homeModules.misty = {lib, ...}: {
    home.username = lib.mkDefault "misty";
    home.homeDirectory = lib.mkDefault "/home/misty";
  };
}
