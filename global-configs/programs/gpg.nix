{ lib, config, ... }:

let
  cfg = config.gpg;
in
{
  options.gpg = {
    enable = lib.mkEnableOption "GPG with custom public key";

    publicKeySource = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the public key file (.asc) to import with ultimate trust.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      publicKeys = lib.mkIf (cfg.publicKeySource != null) [
        {
          source = cfg.publicKeySource;
          trust = "ultimate";
        }
      ];
      homedir = "${config.xdg.dataHome}/gnupg";
    };
  };
}
