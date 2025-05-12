{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = ./me/mistylappytappy.asc;
        trust = "ultimate";
      }
    ];
    homedir = "${config.xdg.dataHome}/gnupg";
  };
}
