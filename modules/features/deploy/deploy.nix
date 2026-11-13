{lib, ...}: let
  # Private half lives in the FOODBOWL_DEPLOY_KEY GitHub secret.
  deployKey = lib.fileContents ./deploy.pub;
  foodbowlWg = "10.100.0.6";
in {
  # On thedogpark: lets CI reach foodbowl's sshd over WireGuard, and nothing else.
  flake.nixosModules.deploy-jump = {pkgs, ...}: {
    users.users.deploy = {
      isSystemUser = true;
      group = "deploy";
      shell = "${pkgs.shadow}/bin/nologin";
      openssh.authorizedKeys.keys = [
        ''restrict,port-forwarding,permitopen="${foodbowlWg}:22" ${deployKey}''
      ];
    };
    users.groups.deploy = {};

    # mkOptionDefault merges with the option's default (misty) instead of replacing it.
    doggate.ssh.allowUsers = lib.mkOptionDefault ["deploy"];
  };

  # On foodbowl: CI activates new generations as root.
  flake.nixosModules.deploy-target = {
    users.users.root.openssh.authorizedKeys.keys = [deployKey];
    services.openssh.settings.PermitRootLogin = "prohibit-password";
  };
}
