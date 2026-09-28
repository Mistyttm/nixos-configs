# Proton Drive over rclone, mounted as a normal folder that Dolphin (and every
# other app) can browse. One feature, both classes:
#   - flake.nixosModules.protonDrive: FUSE + the sops secrets the login needs
#   - flake.homeModules.protonDrive:  the rclone remote and the FUSE mount
{self, ...}: {
  flake.nixosModules.protonDrive = {
    config,
    lib,
    ...
  }: let
    cfg = config.doggate.protonDrive;
    secret = {
      sopsFile = self.secrets.protondrive;
      owner = cfg.user;
    };
  in {
    options.doggate.protonDrive = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "misty";
        description = "User that owns the decrypted Proton Drive secrets.";
      };
      totp = lib.mkEnableOption "an OTP secret so rclone can log in to an account with two-factor authentication";
    };

    config = {
      # Provides the setuid fusermount3 wrapper that `rclone mount` needs.
      programs.fuse.enable = true;

      sops.secrets = lib.mkMerge [
        {
          protondrive_username = secret;
          protondrive_password = secret;
        }
        (lib.mkIf cfg.totp {
          protondrive_otp_secret_key = secret;
        })
      ];
    };
  };

  flake.homeModules.protonDrive = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.puppy.protonDrive;
  in {
    options.programs.puppy.protonDrive = {
      enable = lib.mkEnableOption "Proton Drive mounted through rclone";
      remoteName = lib.mkOption {
        type = lib.types.str;
        default = "proton";
        description = "Name of the rclone remote.";
      };
      mountPoint = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/ProtonDrive";
        description = "Directory the drive is mounted on.";
      };
      usernameFile = lib.mkOption {
        type = lib.types.str;
        description = "File containing the Proton account email.";
      };
      passwordFile = lib.mkOption {
        type = lib.types.str;
        description = "File containing the account password, already obscured with `rclone obscure`.";
      };
      otpSecretKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "File containing the obscured TOTP secret key, for accounts with 2FA.";
      };
    };

    config = lib.mkIf cfg.enable {
      # NOTE: programs.rclone owns ~/.config/rclone/rclone.conf. It is rewritten
      # from this declaration on every login, so other remotes must be declared
      # here too.
      programs.rclone = {
        enable = true;
        remotes.${cfg.remoteName} = {
          config = {
            type = "protondrive";
            # Failed or cancelled uploads leave a draft that makes the retry fail
            # with "422 ... already exists (Code=2500)"; this replaces the draft.
            replace_existing_draft = true;
            # Upstream advises disabling the metadata cache for mounts, since it
            # is not invalidated by changes made from other clients.
            enable_caching = false;
          };
          secrets =
            {
              username = cfg.usernameFile;
              password = cfg.passwordFile;
            }
            // lib.optionalAttrs (cfg.otpSecretKeyFile != null) {
              otp_secret_key = cfg.otpSecretKeyFile;
            };
          mounts."/" = {
            enable = true;
            mountPoint = cfg.mountPoint;
            logLevel = "NOTICE";
            options = {
              vfs-cache-mode = "full";
              vfs-cache-max-size = "10G";
            };
          };
        };
      };
    };
  };
}
