{...}: {
  flake.nixosModules.ssh = {
    config,
    lib,
    ...
  }: let
    cfg = config.doggate.ssh;
    hasAuthorizedKey = user: let
      keys = config.users.users.${user}.openssh.authorizedKeys;
    in
      keys.keys != [] || keys.keyFiles != [];
  in {
    options.doggate.ssh = {
      hardened = lib.mkEnableOption ''
        key-only SSH: disables password and keyboard-interactive auth and
        root login, and restricts logins to `allowUsers`
      '';

      allowUsers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["misty"];
        description = "Users allowed to log in over SSH when `hardened` is enabled.";
      };
    };

    config = lib.mkMerge [
      {services.openssh.enable = true;}

      (lib.mkIf cfg.hardened {
        # Refuse to build a config that would lock every allowed user out.
        assertions =
          map (user: {
            assertion = hasAuthorizedKey user;
            message = "doggate.ssh.hardened: user '${user}' has no SSH authorized keys and would be locked out.";
          })
          cfg.allowUsers;

        services.openssh.settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = cfg.allowUsers;
        };
      })
    ];
  };
}
